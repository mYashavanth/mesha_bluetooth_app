import 'package:flutter/material.dart';
import 'package:mesha_bluetooth_data_retrieval/views/uploading_data.dart';

class SystemDetails extends StatefulWidget {
  final List<dynamic> data;
  const SystemDetails({super.key, required this.data});
  @override
  State<SystemDetails> createState() => _SystemDetailsState();
}

class _SystemDetailsState extends State<SystemDetails> {
  final _formKey = GlobalKey<FormState>();

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

  void proceed() {
    if (_formKey.currentState!.validate()) {
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

      print(formData);

      // Navigate to the next page (replace `NextPage()` with your actual page)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UploadingData()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("System Details")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildTextField("Customer Name*", customerNameController,
                    required: true),
                SizedBox(height: 16), // Added space
                buildTextField("Mobile Number", mobileNumberController,
                    keyboardType: TextInputType.phone),
                SizedBox(height: 16), // Added space
                buildTextField("Place*", placeController, required: true),
                SizedBox(height: 16), // Added space
                buildTextField("Battery Brand", batteryBrandController),
                SizedBox(height: 16), // Added space
                buildTextField(
                    "Battery Capacity (Ah)*", batteryCapacityController,
                    required: true),
                SizedBox(height: 16), // Added space
                buildTextField("Battery Rating*", batteryRatingController,
                    required: true),
                SizedBox(height: 16), // Added space
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
                  SizedBox(height: 16), // Added space
                  buildTextField(
                      "Battery Serial Number", batterySerialController)
                ],
                if (is24V) ...[
                  SizedBox(height: 16), // Added space
                  buildTextField(
                      "Battery 1 - Serial Number", battery1SerialController),
                  SizedBox(height: 16), // Added space
                  buildTextField(
                      "Battery 2 - Serial Number", battery2SerialController),
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
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool required = false,
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
        return null;
      },
    );
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Next Page")),
      body: Center(child: Text("Next Page Content Here")),
    );
  }
}
