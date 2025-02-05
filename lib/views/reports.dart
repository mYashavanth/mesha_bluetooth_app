import 'package:flutter/material.dart';
import 'package:mesha_bluetooth_data_retrieval/components/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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

// Track the index of the selected button
  int _selectedIndex = 0;

  // Function to handle button press and update the selected index
  void _onButtonPressed(int index, String text) {
    setState(() {
      _selectedIndex = index; // Update selected button
    });
    print("Selected button: $text");
  }

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
        title: Text(
          'Reports',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
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
// Sorting Buttons (Wrapped in SingleChildScrollView)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildButton("All", 0),
                    const SizedBox(width: 8),
                    _buildButton("Reports", 1),
                    const SizedBox(width: 8),
                    _buildButton("CSV", 2),
                    const SizedBox(width: 8),
                    _buildButton("Duration", 3),
                  ],
                ),
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
            BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }

// Helper method to build buttons
  Widget _buildButton(String text, int index) {
    // Check if this button is selected
    bool isActive = _selectedIndex == index;

    return IntrinsicWidth(
      child: OutlinedButton(
        onPressed: () =>
            _onButtonPressed(index, text), // Change active state on press
        style: OutlinedButton.styleFrom(
          backgroundColor:
              Colors.transparent, // Transparent for inactive green buttons
          foregroundColor: isActive
              ? Colors.green // White text for active button
              : Colors.black87, // Black text for inactive gray button
          side: BorderSide(
              color: isActive ? Colors.green : Colors.grey), // Border color
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isActive
                ? Colors.green // White text for active button
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}
