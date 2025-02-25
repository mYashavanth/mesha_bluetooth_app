import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mesha_bluetooth_data_retrieval/views/change_password.dart';
import 'package:mesha_bluetooth_data_retrieval/views/home_bluetooth.dart';
import 'package:mesha_bluetooth_data_retrieval/views/login.dart';
import 'package:mesha_bluetooth_data_retrieval/views/my_profile.dart';
import 'package:mesha_bluetooth_data_retrieval/views/profile.dart';
import 'package:mesha_bluetooth_data_retrieval/views/reports.dart';
import 'package:mesha_bluetooth_data_retrieval/views/splash_screen.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00B562), // Customize the seed color
          brightness: Brightness.light, // Use light mode
        ),
        useMaterial3: true,
        // textTheme: Typography.material2021(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('zh'), // Chinese
        Locale('hi'), // Hindi
      ],
      home: BluetoothTerminalApp(),
      routes: {
        '/login': (context) => const LogIn(),
        '/home': (context) => const BluetoothDeviceManager(),
        '/reports': (context) => const ReportsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/my_profile': (context) => MyProfile(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/test': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isScanning = false;
  final List<ScanResult> _devices = [];
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _targetCharacteristic;
  String? _retrievedData; // Store retrieved data

  // Request permissions and ensure Bluetooth is enabled
  Future<bool> _requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        print('Bluetooth not supported on this device');
        return false;
      }

      // Check if Bluetooth is ON
      if (await FlutterBluePlus.adapterState.first !=
          BluetoothAdapterState.on) {
        print('Bluetooth is off, please turn it on');
        await FlutterBluePlus.turnOn(); // Prompt user to enable Bluetooth
        return false;
      }

      return true;
    } else {
      print('Permissions not granted');
      return false;
    }
  }

  // Start scanning for devices
  Future<void> _startScan() async {
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      // print(
      //     '++++++++++++++++++++++++++++++++++++++results+++++++++++++++++++++++++++++++++++++++++++++');
      // print(results);
      // print(
      //     '++++++++++++++++++++++++++++++++++++++results+++++++++++++++++++++++++++++++++++++++++++++');
      setState(() {
        _devices.clear();
        _devices.addAll(results);
        _isScanning = false;
      });
    }, onError: (e) {
      print('Scan error: $e');
    });
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
    setState(() => _isScanning = false);
  }

  // Connect to a selected device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        _connectedDevice = device;
        print(
            '++++++++++++++++++++++++++++++++++++++_connectedDevice+++++++++++++++++++++++++++++++++++++++++++++');
        print(_connectedDevice);
        print(
            '++++++++++++++++++++++++++++++++++++++_connectedDevice+++++++++++++++++++++++++++++++++++++++++++++');
      });

      print('Connected to ${device.remoteId}');

      // Discover services and start fetching data
      await _discoverServices();
    } catch (e) {
      print('Failed to connect: $e');
    }
  }

  // Disconnect from the device
  Future<void> _disconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      setState(() {
        _connectedDevice = null;
        _targetCharacteristic = null;
      });
      print('Disconnected');
    }
  }

  // Discover available services & characteristics
  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    List<BluetoothService> services =
        await _connectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      print(
          '++++++++++++++++++++++++++++++++++++++service+++++++++++++++++++++++++++++++++++++++++++++');
      print(service);
      print(
          '++++++++++++++++++++++++++++++++++++++service+++++++++++++++++++++++++++++++++++++++++++++');
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        print(
            'Service: ${service.uuid}, Characteristic: ${characteristic.uuid}');

        // Check if characteristic supports reading
        if (characteristic.properties.read) {
          _targetCharacteristic = characteristic;
          // print(
          //     '++++++++++++++++++++++++++++++++++++++_targetCharacteristic+++++++++++++++++++++++++++++++++++++++++++++');
          // print(_targetCharacteristic);
          // print(
          //     '++++++++++++++++++++++++++++++++++++++_targetCharacteristic+++++++++++++++++++++++++++++++++++++++++++++');
          _readCharacteristic(characteristic);
        }

        // Check if characteristic supports notifications (live updates)
        if (characteristic.properties.notify) {
          _subscribeToCharacteristic(characteristic);
        }
      }
    }
  }

  // Read data from a characteristic
  Future<void> _readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    print(
        '++++++++++++++++++++++++++++++++++++++Characteristic+++++++++++++++++++++++++++++++++++++++++++++');
    print(characteristic);
    print(
        '++++++++++++++++++++++++++++++++++++++Characteristic+++++++++++++++++++++++++++++++++++++++++++++');
    try {
      List<int> value = await characteristic.read();
      String data = utf8.decode(value);
      setState(() {
        _retrievedData = data; // Update UI with retrieved data
      });
      print('Data Read: $data');
    } catch (e) {
      print('Error reading characteristic: $e');
    }
  }

  // Subscribe for live data updates
  Future<void> _subscribeToCharacteristic(
      BluetoothCharacteristic characteristic) async {
    characteristic.lastValueStream.listen((value) {
      String data = String.fromCharCodes(value);
      setState(() {
        _retrievedData = data; // Update UI with live data
      });
      print('Live Data: $data');
    });

    await characteristic.setNotifyValue(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Devices')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _isScanning ? _stopScan : _startScan,
            child: Text(_isScanning ? 'Stop Scan' : 'Start Scan'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index].device;
                return ListTile(
                  title: Text(device.remoteId.toString()),
                  subtitle: Text(_devices[index].advertisementData.advName ??
                      'Unknown Device'),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToDevice(device),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
          ),
          if (_connectedDevice != null)
            Column(
              children: [
                Text('Connected to: ${_connectedDevice!.remoteId}'),
                ElevatedButton(
                  onPressed: _disconnectDevice,
                  child: const Text('Disconnect'),
                ),
                if (_retrievedData != null) // Show retrieved data
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Received Data: $_retrievedData',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class BluetoothTerminalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BluetoothTerminalScreen(),
    );
  }
}

class BluetoothTerminalScreen extends StatefulWidget {
  @override
  _BluetoothTerminalScreenState createState() =>
      _BluetoothTerminalScreenState();
}

class _BluetoothTerminalScreenState extends State<BluetoothTerminalScreen> {
  BluetoothDevice? connectedDevice;
  List<BluetoothDevice> pairedDevices = [];
  List<BluetoothDevice> scannedDevices = [];
  BluetoothCharacteristic? txCharacteristic;
  BluetoothCharacteristic? rxCharacteristic;
  List<String> messages = [];
  String? _retrievedData = "";
  bool isScanning = false;
  bool isBluetoothOn = true;
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkBluetoothStatus();
    getPairedDevices();
  }

  /// Check if Bluetooth is enabled
  void checkBluetoothStatus() async {
    bool enabled = await FlutterBluePlus.isSupported;
    setState(() {
      isBluetoothOn = enabled;
    });
  }

  /// Fetch Paired (Bonded) Devices
  void getPairedDevices() async {
    List<BluetoothDevice> bondedDevices = await FlutterBluePlus.bondedDevices;
    setState(() {
      pairedDevices = bondedDevices;
    });
  }

  /// Start Scanning for New Devices
  void startScan() {
    setState(() {
      scannedDevices.clear();
      isScanning = true;
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scannedDevices = results
            .map((r) => r.device)
            .where((device) =>
                !pairedDevices.contains(device) && device.platformName != "")
            .toList();
      });
    }).onDone(() {
      setState(() {
        isScanning = false;
      });
    });
  }

  /// Connect to a Selected Device
  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
      if (!pairedDevices.contains(device)) {
        pairedDevices.add(device);
      }
      scannedDevices.remove(device);
    });
    discoverServices();
    // await device.createBond();
  }

  /// Discover Bluetooth Services
  void discoverServices() async {
    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.write) {
          txCharacteristic = char;
        }
        if (char.properties.notify || char.properties.read) {
          rxCharacteristic = char;
          rxCharacteristic!.setNotifyValue(true);
          rxCharacteristic!.lastValueStream.listen((value) {
            String receivedData = String.fromCharCodes(value);
            print(receivedData);
            // print(
            //     '+++++++++++++++++++++++++++++++++++++++_retrievedData+++++++++++++++++++++++++++++++++++++++++++++');
            // print(_retrievedData);
            // print(
            //     '+++++++++++++++++++++++++++++++++++++++_retrievedData+++++++++++++++++++++++++++++++++++++++++++++');
            setState(() {
              messages.add("Received: $receivedData");
              _retrievedData = _retrievedData! + receivedData;
            });
          });
        }
      }
    }
  }

  void convertAndSaveCSV() async {
    List<String> rows = _retrievedData!.split('\n');
    List<String> headers = 'id,date,time,value1,value2'.split(',');

    List<Map<String, dynamic>> allData = [];

    // Fix: Initialize `data` inside the loop to avoid reference issues
    for (int i = 1; i < rows.length - 2; i++) {
      List<String> row = rows[i].split(',');
      Map<String, dynamic> data = {}; // Ensure new map for each row

      for (int j = 0; j < headers.length; j++) {
        data[headers[j]] = row[j];
      }
      allData.add(data);
    }

    print(allData); // Check the structured list of objects

    // Convert back to CSV format
    List<List<String>> csvData = [
      headers, // Add headers as the first row
      ...allData.map(
        (map) =>
            headers.map((header) => (map[header] ?? "").toString()).toList(),
      )
    ];

    String csvString = const ListToCsvConverter().convert(csvData);

    // Save CSV file
    final directory =
        await getExternalStorageDirectory(); // Use `getApplicationDocumentsDirectory()` for iOS
    final path = "${directory?.path}/output_data.csv";

    final file = File(path);
    await file.writeAsString(csvString);

    print("CSV file saved at: $path");
  }

  /// Send Data to Bluetooth Device
  void sendData(String data) async {
    if (txCharacteristic != null) {
      await txCharacteristic!.write(data.codeUnits);
      // setState(() {
      //   messages.add("Sent: $data");
      // });
    }
  }

  /// Send *GET$ Command to Retrieve Data
  void retrieveData() {
    _retrievedData = "";
    sendData("*GET\$");
  }

  /// UI for Connected Device
  Widget buildConnectedDeviceUI() {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(_retrievedData ?? ""),
          ),
        ),
        Text(
          "Connected to: ${connectedDevice?.platformName ?? "Unknown"}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(messages[index]));
            },
          ),
        ),
        ElevatedButton(
          onPressed: retrieveData,
          child: Text("Retrieve Data"),
        ),
        ElevatedButton(
          onPressed: convertAndSaveCSV,
          child: Text('ToCSV'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(labelText: "Enter message"),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendData(messageController.text);
                  messageController.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth Terminal")),
      body: connectedDevice == null
          ? Column(
              children: [
                isBluetoothOn
                    ? ElevatedButton(
                        onPressed: startScan,
                        child: Text(isScanning ? "Scanning..." : "Start Scan"),
                      )
                    : Text("Bluetooth is OFF. Please enable it."),

                // Connected & Paired Devices Section
                if (pairedDevices.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Paired & Connected Devices",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pairedDevices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              pairedDevices[index].platformName ?? "Unknown"),
                          subtitle:
                              Text(pairedDevices[index].remoteId.toString()),
                          onTap: () => connectToDevice(pairedDevices[index]),
                        );
                      },
                    ),
                  ),
                ],

                // Scanned Devices Section
                if (scannedDevices.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Available Devices",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: scannedDevices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              scannedDevices[index].platformName ?? "Unknown"),
                          subtitle:
                              Text(scannedDevices[index].remoteId.toString()),
                          onTap: () => connectToDevice(scannedDevices[index]),
                        );
                      },
                    ),
                  ),
                ],
              ],
            )
          : buildConnectedDeviceUI(),
    );
  }
}
