import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

class ReportDatePickerSheet extends StatefulWidget {
  final FlutterSecureStorage storage;

  const ReportDatePickerSheet({super.key, required this.storage});

  @override
  State<ReportDatePickerSheet> createState() => _ReportDatePickerSheetState();
}

class _ReportDatePickerSheetState extends State<ReportDatePickerSheet>
    with SingleTickerProviderStateMixin {
  DateTime? fromDate;
  TimeOfDay? fromTime;
  DateTime? toDate;
  TimeOfDay? toTime;
  List<dynamic> apiFiles = [];
  bool isLoading = false;
  Map<String, bool> fileDownloadingStates = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Separate files by type
    final pdfFiles = apiFiles.where((file) {
      final fileName = file['saved_file_name'] ?? file['file_name'];
      return fileName?.endsWith('.pdf') ?? false;
    }).toList();

    final csvFiles = apiFiles.where((file) {
      final fileName = file['saved_file_name'] ?? file['file_name'];
      return fileName?.endsWith('.csv') ?? false;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          // height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select date and time range',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 16),

              // From Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Start time',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const SizedBox(width: 10.0),
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
              const Divider(height: 16),

              // To Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('End time',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const SizedBox(width: 10.0),
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
              const Divider(height: 16),

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: 'PDF Files'),
                    Tab(text: 'CSV Files'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // PDF Files Tab
                    _buildFilesList(pdfFiles, 'pdf'),

                    // CSV Files Tab
                    _buildFilesList(csvFiles, 'csv'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (fromDate != null &&
                        fromTime != null &&
                        toDate != null &&
                        toTime != null) {
                      setState(() => isLoading = true);

                      // Format dates for API
                      final startDate =
                          '${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}';
                      final endDate =
                          '${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}';
                      final startTime =
                          '${fromTime!.hour.toString().padLeft(2, '0')}:${fromTime!.minute.toString().padLeft(2, '0')}:00';
                      final endTime =
                          '${toTime!.hour.toString().padLeft(2, '0')}:${toTime!.minute.toString().padLeft(2, '0')}:00';

                      // Get token from secure storage
                      final token = await widget.storage.read(key: 'userToken');
                      print({
                        'token': token,
                        'startDate': startDate,
                        'endDate': endDate,
                        'startTime': startTime,
                        'endTime': endTime,
                      });
                      try {
                        final response = await http.post(
                          Uri.parse(
                              'https://bt.meshaenergy.com/apis/app/reports/dowload-list/csv-pdf'),
                          body: {
                            'token': token,
                            'startDate': startDate,
                            'endDate': endDate,
                            'startTime': startTime,
                            'endTime': endTime,
                          },
                        );
                        print(response.body);
                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);
                          setState(() {
                            apiFiles = data;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error fetching files: ${response.statusCode}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } finally {
                        setState(() => isLoading = false);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select both From and To dates and times.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            style: TextButton.styleFrom(
              backgroundColor: isLoading
                  ? const Color(0xFF00B562).withOpacity(0.5)
                  : const Color(0xFF00B562),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Get Reports',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilesList(List<dynamic> files, String type) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : files.isEmpty
            ? Center(
                child: Text(
                  type == 'pdf'
                      ? 'No PDF files available'
                      : 'No CSV files available',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final fileName = file['saved_file_name'] ?? file['file_name'];
                  final fileId = file['id'].toInt();
                  final isDownloading =
                      fileDownloadingStates[fileName] ?? false;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        leading: SvgPicture.asset(
                          type == 'csv'
                              ? 'assets/svg/csv.svg'
                              : 'assets/svg/pdf.svg',
                          width: 40,
                          height: 40,
                        ),
                        title: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fileName ?? 'Unknown file',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['created_date'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              file['created_time'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        trailing: isDownloading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  _downloadAndOpenFile(
                                    fileName,
                                    type,
                                    fileId,
                                  );
                                },
                              ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              );
  }

  Future<void> _downloadAndOpenFile(
      String? fileName, String type, int? fileId) async {
    if (fileName == null) return;
    print('Downloading $fileName, id: $fileId');
    setState(() {
      fileDownloadingStates[fileName] = true;
    });
    final token = await widget.storage.read(key: 'userToken');

    try {
      final url = type == 'pdf'
          ? 'https://bt.meshaenergy.com/apis/pdf-report/$fileName'
          : 'https://bt.meshaenergy.com/apis/app/reports/dowload-list/csv/$token/$fileId';
      print('Downloading from URL: $url');

      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        // Get the app's documents directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Write the downloaded file
        await file.writeAsBytes(response.bodyBytes);

        // Open the file
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          throw Exception('Could not open file');
        }
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        fileDownloadingStates[fileName] = false;
      });
    }
  }
}
