import 'package:flutter/material.dart';
import 'package:mesha_bluetooth_data_retrieval/views/dry.dart';
import 'package:mesha_bluetooth_data_retrieval/views/uploading_data.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SystemDetails extends StatefulWidget {
  final BluetoothDevice? device;
  const SystemDetails({super.key, this.device});
  @override
  State<SystemDetails> createState() => _SystemDetailsState();
}

class _SystemDetailsState extends State<SystemDetails> {
  final _formKey = GlobalKey<FormState>();

  final storage = const FlutterSecureStorage();

  TextEditingController customerNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController batteryBrandController = TextEditingController();
  TextEditingController batteryCapacityController = TextEditingController();
  TextEditingController batteryRatingController = TextEditingController();
  TextEditingController batterySerialController = TextEditingController();
  TextEditingController battery1SerialController = TextEditingController();
  TextEditingController battery2SerialController = TextEditingController();

  String? batterySystem;
  bool is24V = false;

  @override
  void initState() {
    super.initState();
    loadFormData(); // Load data when the page initializes
  }

  Future<void> saveFormData(String fileName) async {
    Map<String, dynamic> formData = {
      "Customer Name": customerNameController.text,
      "Mobile Number": mobileNumberController.text,
      "Place": placeController.text,
      "Battery Brand": batteryBrandController.text,
      "Battery Capacity (Ah)": batteryCapacityController.text,
      "Battery Rating": batteryRatingController.text,
      "Battery System": batterySystem,
      "Battery Serial Number": is24V
          ? {
              "Battery 1 Serial Number": battery1SerialController.text,
              "Battery 2 Serial Number": battery2SerialController.text
            }
          : batterySerialController.text
    };

    // Save the form data as a JSON string in secure storage
    await storage.write(key: fileName, value: jsonEncode(formData));
  }

  Future<void> loadFormData() async {
    final fileName =
        await storage.read(key: 'csvFilePath'); // Get the file name
    if (fileName != null) {
      final savedData = await storage.read(key: fileName); // Load saved data
      if (savedData != null) {
        Map<String, dynamic> formData = jsonDecode(savedData);

        // Populate the fields with the saved data
        setState(() {
          customerNameController.text = formData["Customer Name"] ?? "";
          mobileNumberController.text = formData["Mobile Number"] ?? "";
          placeController.text = formData["Place"] ?? "";
          batteryBrandController.text = formData["Battery Brand"] ?? "";
          batteryCapacityController.text =
              formData["Battery Capacity (Ah)"] ?? "";
          batteryRatingController.text = formData["Battery Rating"] ?? "";
          batterySystem = formData["Battery System"];
          is24V = batterySystem == "24V";

          if (is24V) {
            battery1SerialController.text = formData["Battery Serial Number"]
                    ["Battery 1 Serial Number"] ??
                "";
            battery2SerialController.text = formData["Battery Serial Number"]
                    ["Battery 2 Serial Number"] ??
                "";
          } else {
            batterySerialController.text =
                formData["Battery Serial Number"] ?? "";
          }
        });
      }
    }
  }

  void proceed() async {
    if (_formKey.currentState!.validate()) {
      final fileName =
          await storage.read(key: 'csvFilePath'); // Get the file name
      if (fileName != null) {
        await saveFormData(fileName); // Save the form data
      }

      // Proceed with the existing logic
      final token = await storage.read(key: 'userToken');
      Map<String, dynamic> data = is24V
          ? {
              "token": token,
              "customer_name": customerNameController.text,
              "mobile": mobileNumberController.text,
              "place": placeController.text,
              "battery_brand": batteryBrandController.text,
              "battery_capacity": batteryCapacityController.text,
              "battery_rating": batteryRatingController.text,
              "battery_system": batterySystem,
              "batter_serial_no_1": battery1SerialController.text,
              "batter_serial_no_2": battery2SerialController.text
            }
          : {
              "token": token,
              "customer_name": customerNameController.text,
              "mobile": mobileNumberController.text,
              "place": placeController.text,
              "battery_brand": batteryBrandController.text,
              "battery_capacity": batteryCapacityController.text,
              "battery_rating": batteryRatingController.text,
              "battery_system": batterySystem,
              "batter_serial_no_1": batterySerialController.text
            };

      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UploadingData(data: data, device: widget.device)));
      }
    }
  }

  @override
  void dispose() {
    // Save the form data when the widget is disposed
    _saveDataOnExit();
    // Dispose all the controllers
    customerNameController.dispose();
    mobileNumberController.dispose();
    placeController.dispose();
    batteryBrandController.dispose();
    batteryCapacityController.dispose();
    batteryRatingController.dispose();
    batterySerialController.dispose();
    battery1SerialController.dispose();
    battery2SerialController.dispose();
    super.dispose();
  }

  Future<void> _saveDataOnExit() async {
    print("Saving data on exit");
    final fileName = await storage.read(key: 'csvFilePath');
    if (fileName != null) {
      print("Saving data");
      await saveFormData(fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        await moveFileToCacheDry(storage);
        await navigateBasedOnPageIndex(storage, context, widget.device);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("System Details"),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildTextField("Customer Name*", customerNameController,
                      required: true, validationType: "letters"),
                  SizedBox(height: 16),
                  buildTextField("Mobile Number*", mobileNumberController,
                      required: true, validationType: "mobile"),
                  SizedBox(height: 16),
                  buildTextField("Place*", placeController,
                      required: true, validationType: "letters"),
                  SizedBox(height: 16),
                  buildTextField("Battery Brand", batteryBrandController,
                      validationType: "letters"),
                  SizedBox(height: 16),
                  buildTextField(
                      "Battery Capacity (Ah)*", batteryCapacityController,
                      required: true, validationType: "alphanumeric"),
                  SizedBox(height: 16),
                  buildTextField("Battery Rating*", batteryRatingController,
                      required: true, validationType: "alphanumeric"),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: batterySystem,
                    decoration: InputDecoration(
                      labelText: "Battery System*",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    items: ["12V", "24V"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        batterySystem = value;
                        is24V = value == "24V";
                      });
                    },
                    validator: (value) =>
                        value == null ? "Please select a battery system" : null,
                  ),
                  if (!is24V) ...[
                    SizedBox(height: 16),
                    buildTextField(
                      "Battery Serial Number*", batterySerialController,
                      // required: true
                    ),
                  ],
                  if (is24V) ...[
                    SizedBox(height: 16),
                    buildTextField(
                      "Battery 1 - Serial Number*", battery1SerialController,
                      // required: true
                    ),
                    SizedBox(height: 16),
                    buildTextField(
                      "Battery 2 - Serial Number*", battery2SerialController,
                      // required: true
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: proceed,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF00B562),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                "Proceed",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool required = false,
      String validationType = "none",
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return "This field is required";
        }
        switch (validationType) {
          case "letters":
            if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value!)) {
              return "Only letters and spaces allowed";
            }
            break;
          case "mobile":
            if (!RegExp(r"^\d{10}$").hasMatch(value!)) {
              return "Enter a valid 10-digit mobile number";
            }
            break;
          case "alphanumeric":
            if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value!)) {
              return "Only letters and numbers allowed";
            }
            break;
          case "numbers":
            if (!RegExp(r"^\d+$").hasMatch(value!)) {
              return "Only numbers allowed";
            }
            break;
        }
        return null;
      },
    );
  }
}
