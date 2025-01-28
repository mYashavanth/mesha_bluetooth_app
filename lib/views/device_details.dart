import 'dart:math'; // Import the math library for pi
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeviceDetailsPage extends StatefulWidget {
  final String deviceName;

  const DeviceDetailsPage({super.key, required this.deviceName});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  // Dummy data for pendingReports
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title horizontally
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // pendingReports Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Reports',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // List of pendingReports
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
                      print("Calendar button clicked!");
                    }, // Use the same onPressed function
                    icon: const Icon(
                      Icons.calendar_today_rounded, // Calendar icon
                      size: 24, // Adjust the size of the icon
                      color: Colors.black54, // Set the icon color
                    ),
                    padding: EdgeInsets.zero, // Remove padding
                    constraints: const BoxConstraints(), // Remove constraints
                  )
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
                      }, // Use the same onPressed function
                      child: const Text(
                        'Reports',
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
    );
  }
}
