import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mesha_bluetooth_data_retrieval/views/downloading_report.dart';

class GenertingReport extends StatefulWidget {
  const GenertingReport({super.key});

  @override
  State<GenertingReport> createState() => _GenertingReportState();
}

class _GenertingReportState extends State<GenertingReport> {
  double progress = 0.0;
  int dotCount = 1; // For animated dots

  @override
  void initState() {
    super.initState();
    simulateProgress();
    animateDots();
  }

  // Simulate progress bar filling up gradually
  void simulateProgress() {
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        progress += 0.1;
        if (progress >= 1.0) {
          progress = 1.0;
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DownloadingReport()),
          );
        }
      });
    });
  }

  // Animate the `...` effect (dots repeating)
  void animateDots() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 3) + 1; // Cycle between 1, 2, 3 dots
      });
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
