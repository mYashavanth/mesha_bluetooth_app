import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mesha_bluetooth_data_retrieval/views/downloading_report.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GenertingReport extends StatefulWidget {
  final String fileUploadId;
  final BluetoothDevice device;

  const GenertingReport(
      {super.key, required this.fileUploadId, required this.device});

  @override
  State<GenertingReport> createState() => _GenertingReportState();
}

class _GenertingReportState extends State<GenertingReport> {
  final storage = const FlutterSecureStorage();
  String fileUploadId = '';
  double progress = 0.0;
  int dotCount = 1; // For animated dots
  bool isFetching = true; // Track API fetching

  String pdfFileName = '';

  Timer? _progressTimer;
  Timer? _dotsTimer;

  @override
  void initState() {
    super.initState();
    fileUploadId = widget.fileUploadId;
    print(fileUploadId);
    generatePdfFileName().then((_) {
      // Start simulating progress only after data is fetched
      simulateProgress();
    });
    animateDots();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _dotsTimer?.cancel();
    super.dispose();
  }

  // Simulate progress bar filling up gradually
  void simulateProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!isFetching) {
        if (mounted) {
          setState(() {
            progress = 1.0;
          });
        }
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          navigateToNextScreen();
        });
      } else {
        if (mounted) {
          setState(() {
            progress += 0.1;
            if (progress >= 0.9) progress = 0.9; // Cap at 90% while waiting
          });
        }
      }
    });
  }

  Future<void> generatePdfFileName() async {
    final token = await storage.read(key: 'userToken');
    try {
      isFetching = true; // Set fetching to true while fetching data
      final data = <String, dynamic>{
        'token': token,
        'scannedFileId': fileUploadId
      };
      final response = await http.post(
          Uri.parse('https://bt.meshaenergy.com/apis/app/get-pdf-report'),
          body: data);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData['errFlag'] == 0) {
          print(responseData['pdfFileName']);
          if (mounted) {
            setState(() {
              pdfFileName = responseData['pdfFileName'].toString();
            });
          }
        } else {
          print(responseData['message']);
        }
      } else {
        print('Failed to generate PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false; // Set fetching to false after data is fetched
        });
      }
    }
  }

  void navigateToNextScreen() {
    print("navigation");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (buildContext) =>
            DownloadingReport(pdfFileName: pdfFileName, device: widget.device),
      ),
    );
  }

  // Animate the `...` effect (dots repeating)
  void animateDots() {
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          dotCount = (dotCount % 3) + 1; // Cycle between 1, 2, 3 dots
        });
      }
    });
  }

  String generateDisplayText() {
    String dots = '.' * dotCount;
    return "Generting report$dots";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Text("Mesha BT device"),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: index == 0 || index == 1
                              ? 1.0
                              : (index == 2 ? progress : 0),
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                generateDisplayText(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: const Color(0xFF204433),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Generating report...",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
