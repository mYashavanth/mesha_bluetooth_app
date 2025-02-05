import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mesha_bluetooth_data_retrieval/views/system_details.dart';


class RetrievingData extends StatefulWidget {
  const RetrievingData({super.key});

  @override
  State<RetrievingData> createState() => _RetrievingDataState();
}

class _RetrievingDataState extends State<RetrievingData> {
  double progress = 0.0;
  List<dynamic> fetchedData = [];
  bool isFetching = true; // Track API fetching
  int dotCount = 1; // For animated dots

  @override
  void initState() {
    super.initState();
    fetchData();
    simulateProgress();
    animateDots();
  }

  // Simulate progress bar filling up gradually
  void simulateProgress() {
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!isFetching) {
        setState(() {
          progress = 1.0;
        });
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          navigateToNextScreen();
        });
      } else {
        setState(() {
          progress += 0.1;
          if (progress >= 0.9) progress = 0.9; // Cap at 90% while waiting
        });
      }
    });
  }

  // Fetch data from API
  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

      if (response.statusCode == 200) {
        setState(() {
          fetchedData = json.decode(response.body);
          isFetching = false; // Mark fetching as done
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isFetching = false;
      });
    }
  }

  void navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SystemDetails(data: fetchedData)),
    );
  }

  // Animate the `...` effect (dots repeating)
  void animateDots() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 3) + 1; // Cycle between 1, 2, 3 dots
      });
    });
  }

  // Format progress text with animated dots
  String getProgressText() {
    int percentage = (progress * 100).toInt();
    String dots = '.' * dotCount; // Generate dot animation
    return "$percentage% data retrieval in progress stay close to the device$dots";
  }

  String generateDisplayText() {
    String dots = '.' * dotCount; // Generate dot animation
    return "Retrieving Data$dots";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Text("M4 Device Name"),
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
                          value: index == 0 ? progress : 0,
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
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
                    const Icon(Icons.cloud_download_outlined,
                        color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      // Ensures text does not overflow
                      child: Text(
                        getProgressText(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        softWrap: true, // Enables text wrapping
                        overflow: TextOverflow
                            .visible, // Ensures text is fully displayed
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
