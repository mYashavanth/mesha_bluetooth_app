import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

import 'package:mesha_bluetooth_data_retrieval/views/retrieving_data.dart'; // Import the math library for pi

import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:mesha_bluetooth_data_retrieval/views/system_details.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceDetailsPage extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  final storage = FlutterSecureStorage();
  BluetoothCharacteristic? txCharacteristic;
  BluetoothCharacteristic? rxCharacteristic;
  List<String> messages = [];
  String? _retrievedData = "";
  final TextEditingController messageController = TextEditingController();
  bool isDeleteConfirmed = false;
  bool isDataRetrievalComplete = true;
  StreamSubscription<List<int>>? _rxSubscription;
  String fileName = '';
  // Dummy data for pendingReports and reportsGenerated
  List<Map<String, String>> pendingReports = [
    {
      'fileName': 'Report 1',
      'date': '2023-10-01',
      'size': '1.2 MB',
      'status': 'Pending'
    },
    {
      'fileName': 'Report 3',
      'date': '2023-10-03',
      'size': '3.0 MB',
      'status': 'Pending'
    },
  ];

  List<Map<String, String>> reportsGenerated = [
    {
      'fileName': 'Report 1',
      'date': '2023-10-01',
      'size': '1.2 MB',
      'status': 'uploaded'
    },
    {
      'fileName': 'Report 3',
      'date': '2023-10-03',
      'size': '3.0 MB',
      'status': 'uploaded'
    },
    {
      'fileName': 'Report 1',
      'date': '2023-10-01',
      'size': '1.2 MB',
      'status': 'uploaded'
    },
    {
      'fileName': 'Report 3',
      'date': '2023-10-03',
      'size': '3.0 MB',
      'status': 'uploaded'
    },
    {
      'fileName': 'Report 1',
      'date': '2023-10-01',
      'size': '1.2 MB',
      'status': 'uploaded'
    },
    {
      'fileName': 'Report 3',
      'date': '2023-10-03',
      'size': '3.0 MB',
      'status': 'uploaded'
    },
  ];

  @override
  void initState() {
    super.initState();
    connectToDevice(widget.device);
  }

  /// Connect to a Selected Device
  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    discoverServices();
  }

  /// Discover Bluetooth Services
  void discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.write) {
          txCharacteristic = char;
        }
        if (char.properties.notify || char.properties.read) {
          rxCharacteristic = char;
          rxCharacteristic!.setNotifyValue(true);
          _rxSubscription = rxCharacteristic!.lastValueStream.listen((value) {
            if (!mounted) return; // Check if the widget is still mounted
            String receivedData = String.fromCharCodes(value);
            setState(() {
              messages.add("Received: $receivedData");
              _retrievedData = _retrievedData! + receivedData;
              print(_retrievedData);
              // Check for "NO RECORDS" and trigger sendData() after 1 minute
              if (_retrievedData!.trim() == "NO RECORDS") {
                // print("Waiting for 1 minute before sending *GET\$...");
                // Future.delayed(const Duration(minutes: 1), () {
                //   if (mounted) {
                //     print("Sending *GET\$ command...");
                //     sendData("*GET\$");
                //   }
                // });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'No Records Found. Please wait for 1 minute before Retirving Data...'),
                    showCloseIcon: true,
                    behavior: SnackBarBehavior.floating, // Make it float on top
                  ),
                );
                isDataRetrievalComplete = true;
              }
              // Check if the received data indicates the end of transmission
              if (_retrievedData!.contains("END")) {
                isDataRetrievalComplete = true;
                convertAndSaveCSV(); // Automatically convert and save CSV
              }
            });
          });
        }
      }
    }
  }

  void convertAndSaveCSV() async {
    if (!isDataRetrievalComplete) return; // Ensure data retrieval is complete

    List<String> rows = _retrievedData!.split('\n');
    if (rows.isEmpty) return; // Ensure there are rows to process

    List<String> headers = 'SN,Date,Time,B1,C'.split(',');

    List<Map<String, dynamic>> allData = [];

    for (int i = 1; i < rows.length - 2; i++) {
      if (rows[i].isEmpty) continue; // Skip empty rows
      List<String> row = rows[i].split(',');
      if (row.length < headers.length) {
        continue;
      }
      // Skip rows with insufficient data

      Map<String, dynamic> data = {};

      for (int j = 0; j < headers.length; j++) {
        data[headers[j]] = row[j];
      }
      allData.add(data);
    }

    List<List<String>> csvData = [
      headers,
      ...allData.map(
        (map) =>
            headers.map((header) => (map[header] ?? "").toString()).toList(),
      )
    ];

    String csvString = const ListToCsvConverter().convert(csvData);

    final directory = await getExternalStorageDirectory();

    // Get current date and time
    String formattedDateTime =
        DateFormat('yyyy-MM-dd_HH:mm:ss').format(DateTime.now());

    // Generate filename with platform name and date-time
    fileName = "${widget.device.platformName}_$formattedDateTime.csv";
    final path = "${directory?.path}/$fileName";

    final file = File(path);
    await file.writeAsString(csvString);
    await storage.write(key: 'csvFilePath', value: path);
    print("CSV file saved at: $path");
    deleteData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SystemDetails(device: widget.device),
      ),
    );
  }

  /// Send Data to Bluetooth Device
  void sendData(String data) async {
    if (txCharacteristic != null) {
      await txCharacteristic!.write(data.codeUnits);
    }
  }

  /// Send *GET$ Command to Retrieve Data
  void retrieveData() async {
    _retrievedData = "";
    isDataRetrievalComplete = false; // Reset the flag
    sendData("*GET\$");
  }

  /// Send *DELETE$ Command
  void deleteData() {
    _retrievedData = "";
    sendData("*DELETE\$"); // First delete command
    setState(() {
      isDeleteConfirmed = !isDeleteConfirmed; // Toggle the button text
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      sendData("*DELETE\$"); // Second delete command after a short delay
      setState(() {
        isDeleteConfirmed = !isDeleteConfirmed; // Toggle the button text
      });
    });
  }

  // Variables to store selected dates and times
  DateTime? fromDate;
  TimeOfDay? fromTime;
  DateTime? toDate;
  TimeOfDay? toTime;

  // Function to show the date-time picker bottom sheet
  void _showDateTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 80,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select date and time range',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text("Done"),
                    ],
                  ),
                  const Divider(
                    height: 16,
                  ),
                  // From Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Start time',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // Select Date Button
                      TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              fromDate = selectedDate;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(100, 40),
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          fromDate != null
                              ? '${fromDate!.toLocal()}'.split(' ')[0]
                              : 'Select Date',
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      // Select Time Button
                      TextButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              fromTime = selectedTime;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(100, 40),
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          fromTime != null
                              ? '${fromTime!.format(context)}'
                              : 'Select Time',
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 16,
                  ),

                  // To Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('End time',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // Select Date Button
                      TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              toDate = selectedDate;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(100, 40),
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          toDate != null
                              ? '${toDate!.toLocal()}'.split(' ')[0]
                              : 'Select Date',
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      // Select Time Button
                      TextButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              toTime = selectedTime;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(100, 40),
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          toTime != null
                              ? '${toTime!.format(context)}'
                              : 'Select Time',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Download Report Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        if (fromDate != null &&
                            fromTime != null &&
                            toDate != null &&
                            toTime != null) {
                          final fromDateTime = DateTime(
                            fromDate!.year,
                            fromDate!.month,
                            fromDate!.day,
                            fromTime!.hour,
                            fromTime!.minute,
                          );
                          final toDateTime = DateTime(
                            toDate!.year,
                            toDate!.month,
                            toDate!.day,
                            toTime!.hour,
                            toTime!.minute,
                          );
                          print('From Date and Time: $fromDateTime');
                          print('To Date and Time: $toDateTime');
                          Navigator.pop(context); // Close the bottom sheet
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please select both From and To dates and times.'),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF00B562),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Download Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _rxSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.device.platformName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Device Paired',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Reports Section
              const Text(
                'Pending Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingReports.length,
                itemBuilder: (context, index) {
                  final report = pendingReports[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        leading: SvgPicture.asset(
                          'assets/svg/csv.svg',
                          width: 40,
                          height: 40,
                        ),
                        title: Text(
                          report['fileName']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${report['date']} - ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${report['size']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                icon: Transform.rotate(
                                  angle: pi / 2,
                                  child: const Icon(
                                    Icons.arrow_circle_right_sharp,
                                    color: Colors.blue,
                                  ),
                                ),
                                onPressed: () {
                                  print("Download ${report['fileName']}");
                                },
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                icon: Icon(
                                  report['status'] == 'uploaded'
                                      ? Icons.cloud_done_rounded
                                      : Icons.cloud_off_rounded,
                                  color: report['status'] == 'uploaded'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                onPressed: () {
                                  print("Upload ${report['fileName']}");
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),

              // Reports Generated Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reports Generated',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showDateTimePicker(
                          context); // Open the date-time picker bottom sheet
                    },
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      size: 24,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Sorting Buttons
              Row(
                children: [
                  IntrinsicWidth(
                    child: OutlinedButton(
                      onPressed: () => {
                        print("Reports button clicked!"),
                      },
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.green)),
                      child: const Text(
                        'Reports',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: OutlinedButton(
                      onPressed: () => {
                        print("CSV button clicked!"),
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      child: const Text(
                        'CSV',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // List of reportsGenerated
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reportsGenerated.length,
                itemBuilder: (context, index) {
                  final report = reportsGenerated[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        leading: SvgPicture.asset(
                          'assets/svg/pdf.svg',
                          width: 40,
                          height: 40,
                        ),
                        title: Text(
                          report['fileName']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${report['date']} - ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${report['size']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                icon: Transform.rotate(
                                  angle: pi / 2,
                                  child: const Icon(
                                    Icons.arrow_circle_right_sharp,
                                    color: Colors.blue,
                                  ),
                                ),
                                onPressed: () {
                                  print("Download ${report['fileName']}");
                                },
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                icon: Icon(
                                  report['status'] == 'uploaded'
                                      ? Icons.cloud_done_rounded
                                      : Icons.cloud_off_rounded,
                                  color: report['status'] == 'uploaded'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                onPressed: () {
                                  print("Upload ${report['fileName']}");
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${reportsGenerated.length} reports generated.',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Cloud data will be archived and deleted after 30 days.',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF848F8B),
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: deleteData,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        isDeleteConfirmed ? "Loading..." : "Start Test",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () => {
                        retrieveData(),
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const RetrievingData(),
                        //   ),
                        // ),
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF00B562),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        // 'Retrieve Data',
                        isDataRetrievalComplete
                            ? "Retrieve Data"
                            : "Retrieving Data",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
