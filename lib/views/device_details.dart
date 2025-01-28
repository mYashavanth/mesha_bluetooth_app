import 'package:flutter/material.dart';

class DeviceDetailsPage extends StatelessWidget {
  final String deviceName;

  const DeviceDetailsPage({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title horizontally
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              deviceName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4), // Add some spacing
            const Text(
              'Device Paired',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green, // Green color for "Device Paired"
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Details for the device will be shown here.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
