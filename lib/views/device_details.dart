import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

import 'package:mesha_bluetooth_data_retrieval/views/retrieving_data.dart'; // Import the math library for pi

class DeviceDetailsPage extends StatefulWidget {
  final String deviceName;

  const DeviceDetailsPage({super.key, required this.deviceName});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.deviceName,
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
                      onPressed: () => {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Start Test',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RetrievingData(),
                          ),
                        ),
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF00B562),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Retrieve Data',
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
