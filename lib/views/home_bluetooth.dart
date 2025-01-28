import 'dart:math'; // Import the math library for pi
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mesha_bluetooth_data_retrieval/components/bottom_navbar.dart';
import 'package:mesha_bluetooth_data_retrieval/views/device_details.dart';

class BluetoothDeviceManager extends StatefulWidget {
  const BluetoothDeviceManager({super.key});

  @override
  State<BluetoothDeviceManager> createState() => _BluetoothDeviceManagerState();
}

class _BluetoothDeviceManagerState extends State<BluetoothDeviceManager> {
  String _userName = 'Amogh';

  // Dummy data for paired devices
  List<Map<String, String>> pairedDevices = [
    {'name': 'Device 1', 'status': 'Connected'},
    {'name': 'Device 2', 'status': 'Not Connected'},
    {'name': 'Device 3', 'status': 'Not Connected'},
    {'name': 'Device 4', 'status': 'Not Connected'},
    {'name': 'Device 5', 'status': 'Not Connected'},
    {'name': 'Device 6', 'status': 'Not Connected'},
  ];

  // Dummy data for available devices
  List<Map<String, String>> availableDevices = [
    {'name': 'New Device 1'},
    {'name': 'New Device 2'},
    {'name': 'New Device 3'},
    {'name': 'New Device 4'},
  ];

  // Dummy data for reports
  List<Map<String, String>> reports = [
    {
      'fileName': 'Report 1',
      'date': '2023-10-01',
      'size': '1.2 MB',
      'status': 'Pending'
    },
    {
      'fileName': 'Report 2',
      'date': '2023-10-02',
      'size': '2.5 MB',
      'status': 'Recent'
    },
    {
      'fileName': 'Report 3',
      'date': '2023-10-03',
      'size': '3.0 MB',
      'status': 'Pending'
    },
    {
      'fileName': 'Report 4',
      'date': '2023-10-04',
      'size': '1.8 MB',
      'status': 'Recent'
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAlertDialog();
    });
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "Action Needed",
              style: TextStyle(fontSize: 24),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "4 Pending Uploads!",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Review and resolve pending uploads.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Dismiss"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green,
                  ),
                  child: const Text("Action"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Function to handle connection state change
  void _connectDevice(int index) {
    setState(() {
      for (int i = 0; i < pairedDevices.length; i++) {
        pairedDevices[i]['status'] = 'Not Connected';
      }
      pairedDevices[index]['status'] = 'Connected';
    });
  }

  // Function to handle new device pairing
  void _pairNewDevice(int index) {
    print("Pairing with ${availableDevices[index]['name']}");
  }

  // Function to handle report action button click
  void _handleReportAction() {
    print("Report action button clicked!");
  }

  // Function to sort reports by status
  void _sortReports(String status) {
    setState(() {
      reports.sort((a, b) => a['status'] == status ? -1 : 1);
    });
  }

  // Function to handle info icon button click
  void _handleInfoButtonClick(int index) {
    final device = pairedDevices[index];

    if (device['status'] == 'Connected') {
      // Navigate to the DeviceDetailsPage if the device is connected
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DeviceDetailsPage(deviceName: device['name']!),
        ),
      );
    } else {
      // Show a full-screen alert dialog if the device is not connected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: Text(
                "Device Not Connected",
                style: TextStyle(fontSize: 24),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "The device is not connected.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please connect the device to view details.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                ),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome back,",
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_userName!",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Ensure the border is circular
                  border: Border.all(
                    color: Color(0xFFDDDDDD),
                    width: 1.0, // Border width
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Color(0xFFECFFF6),
                  child: Text(
                    _userName.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paired Devices',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pairedDevices.length,
                  itemBuilder: (context, index) {
                    final device = pairedDevices[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding:
                              EdgeInsets.zero, // Remove internal padding
                          minVerticalPadding: 0, // Reduce vertical padding
                          dense: true, // Make the ListTile more compact
                          leading: Text(
                            device['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                device['status']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: device['status'] == 'Connected'
                                      ? Colors.green
                                      : Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.info_outline,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () => _handleInfoButtonClick(index),
                              ),
                            ],
                          ),
                          onTap: () => _connectDevice(index),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pair New Device',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Implement scan functionality
                    },
                    icon: Icon(
                      Icons.sync_sharp,
                      size: 20,
                      color: Colors.black54,
                    ),
                    label: const Text(
                      'Scan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 190,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = availableDevices[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding:
                              EdgeInsets.zero, // Remove internal padding
                          minVerticalPadding: 0, // Reduce vertical padding
                          dense: true, // Make the ListTile more compact
                          leading: Text(
                            device['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Pair',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _pairNewDevice(index),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              // Reports Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reports',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: _handleReportAction,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.all(0),
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
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
                      onPressed: () => _sortReports('Pending'),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: OutlinedButton(
                      onPressed: () => _sortReports('Recent'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      child: const Text(
                        'Recent',
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
              // List of Reports
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
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
                              width: 40, // Adjust the width to reduce spacing
                              child: IconButton(
                                icon: Transform.rotate(
                                  angle: pi /
                                      2, // Rotate 90 degrees (pi/2 radians)
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
                              width: 35, // Adjust the width to reduce spacing
                              child: IconButton(
                                icon: Icon(
                                  report['status'] == 'Recent'
                                      ? Icons.cloud_done_rounded
                                      : Icons.cloud_off_rounded,
                                  color: report['status'] == 'Recent'
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
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
