import 'dart:math'; // Import the math library for pi
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mesha_bluetooth_data_retrieval/components/bottom_navbar.dart';
import 'package:mesha_bluetooth_data_retrieval/views/device_details.dart';

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDeviceManager extends StatefulWidget {
  const BluetoothDeviceManager({super.key});

  @override
  State<BluetoothDeviceManager> createState() => _BluetoothDeviceManagerState();
}

class _BluetoothDeviceManagerState extends State<BluetoothDeviceManager> {
  String _userName = 'Amogh';

  List<BluetoothDevice> _pairedDevices = [];
  List<BluetoothDevice> _scannedDevices = [];

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
    _checkBluetoothStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAlertDialog();
    });
  }

  /// Check Bluetooth Status and Request Permissions
  Future<void> _checkBluetoothStatus() async {
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) return;

    // Ensure Bluetooth is on
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      print('Bluetooth is off. Asking user to enable it...');
      await FlutterBluePlus.turnOn();
      _waitForBluetoothOn();
    } else {
      _getBluetoothDevices();
    }
  }

  /// Wait for the user to turn Bluetooth on, then start scanning
  void _waitForBluetoothOn() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        print('Bluetooth is now ON. Scanning...');
        _getBluetoothDevices();
      } else {
        print('Bluetooth is still OFF. Waiting...');
      }
    });
  }

  /// Request Permissions for Bluetooth and Location
  Future<bool> _requestPermissions() async {
    var scanPermission = await Permission.bluetoothScan.request();
    var connectPermission = await Permission.bluetoothConnect.request();
    var locationPermission = await Permission.location.request();

    if (scanPermission.isGranted &&
        connectPermission.isGranted &&
        locationPermission.isGranted) {
      if (!await FlutterBluePlus.isSupported) {
        print('Bluetooth not supported on this device');
        return false;
      }
      return true;
    } else {
      print('Permissions not granted');
      return false;
    }
  }

  /// Get Paired Devices and Start Scanning for Nearby Devices
  Future<void> _getBluetoothDevices() async {
    setState(() {
      _pairedDevices.clear();
      _scannedDevices.clear();
    });

    // Get Paired Devices
    List<BluetoothDevice> bondedDevices = await FlutterBluePlus.bondedDevices;
    setState(() {
      _pairedDevices = bondedDevices;
    });

    // Start Scanning for Nearby Devices
    await _scanForDevices();
  }

  /// Scan for Nearby Devices
  Future<void> _scanForDevices() async {
    setState(() {
      _scannedDevices.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scannedDevices = results
            .map((r) => r.device)
            .where((device) =>
                !_pairedDevices.contains(device) &&
                device.platformName.isNotEmpty)
            .toList();
      });
    });

    await Future.delayed(Duration(seconds: 5)); // Ensure scan runs for 5 sec
    FlutterBluePlus.stopScan();

    print('Paired Devices: $_pairedDevices');
    print('Scanned Devices: $_scannedDevices');
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Scanned Devices: $_scannedDevices'),
    //     showCloseIcon: true,
    //     behavior: SnackBarBehavior.floating, // Make it float on top
    //   ),
    // );
  }

  Widget _buildDeviceList({
    required String title,
    required List<BluetoothDevice> devices,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title == "Scanned Devices"
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _scanForDevices();
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
              )
            : Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
        SizedBox(height: 16),
        SizedBox(
          height: devices.length * 62.0,
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceCard(device: device);
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              const SizedBox(height: 12), // Add spacing above the divider
              const Divider(thickness: 0),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Dismiss"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green,
                    ),
                    child: const Text("Action"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Function to handle connection state change

  // Function to handle new device pairing

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
              _buildDeviceList(
                  title: "Paired Devices", devices: _pairedDevices),
              SizedBox(height: 24),
              _buildDeviceList(
                  title: "Scanned Devices", devices: _scannedDevices),

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
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.green)),
                      child: const Text(
                        'Pending',
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

class DeviceCard extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceCard({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isConnected = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _checkIfConnected();
  }

  /// Check if the device is already connected
  Future<void> _checkIfConnected() async {
    final isConnected = await widget.device.isConnected;
    setState(() {
      _isConnected = isConnected;
    });
  }

  /// Connect to the device
  Future<void> _connectDevice() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await widget.device.connect();
      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });
    } catch (e) {
      print("Failed to connect: $e");
      setState(() {
        _isConnecting = false;
      });
    }
  }

  /// Disconnect from the device
  Future<void> _disconnectDevice() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await widget.device.disconnect();
      setState(() {
        _isConnected = false;
        _isConnecting = false;
      });
    } catch (e) {
      print("Failed to disconnect: $e");
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: SizedBox(
            width: 170,
            child: Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              widget.device.platformName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isConnecting)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              else
                Text(
                  _isConnected ? "Connected" : "Not Connected",
                  style: TextStyle(
                    fontSize: 14,
                    color: _isConnected ? Colors.green : Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (_isConnected)
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.grey.shade500),
                  onPressed: () => _showDeviceInfo(widget.device),
                ),
            ],
          ),
          onTap: _isConnected ? _disconnectDevice : _connectDevice,
        ),
        Divider(),
      ],
    );
  }

  void _showDeviceInfo(BluetoothDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeviceDetailsPage(device: device),
      ),
    );
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: Text("Device Info"),
    //       content: Text(
    //           "Device Name: ${device.platformName}\nID: ${device.remoteId}"),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: Text("Close"),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}
