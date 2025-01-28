import 'package:flutter/material.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  // Variables to hold the initial user data
  String initialName = "John Doe";
  String initialEmail = "johndoe@example.com";
  String initialMobile = "1234567890";
  String initialPlace = "New York";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with user data
    nameController.text = initialName;
    emailController.text = initialEmail;
    mobileController.text = initialMobile;
    placeController.text = initialPlace;
  }

  // Function to handle update
  void updateProfile() {
    if (_formKey.currentState!.validate()) {
      String updatedName = nameController.text.trim();
      String updatedEmail = emailController.text.trim();
      String updatedMobile = mobileController.text.trim();
      String updatedPlace = placeController.text.trim();

      // Simulate saving data and show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );

      // Print updated values for debugging
      print("Updated Name: $updatedName");
      print("Updated Email: $updatedEmail");
      print("Updated Mobile: $updatedMobile");
      print("Updated Place: $updatedPlace");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title horizontally
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true, // Allows resizing when the keyboard opens
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name cannot be empty';
                          } else if (!RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(value)) {
                            return 'Name should contain only letters and spaces';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          } else if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mobile Number Field
                      TextFormField(
                        controller: mobileController,
                        decoration: const InputDecoration(
                          labelText: "Mobile Number",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mobile number cannot be empty';
                          } else if (value.length != 10 ||
                              !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Mobile number should be 10 digits long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Place Field
                      TextFormField(
                        controller: placeController,
                        decoration: const InputDecoration(
                          labelText: "Place",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Place cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: updateProfile,
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text("Update Profile"),
        ),
      ),
    );
  }
}
