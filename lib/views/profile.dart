import 'package:flutter/material.dart';
import 'package:mesha_bluetooth_data_retrieval/components/bottom_navbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Example user data
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String userName = "User";
  final String userTag = "Pro";
  final String email = "john.doe@example.com";
  final String mobileNumber = "+1234567890";
  final int dataRetrieved = 300;

  Future<void> _loadUserName() async {
    String? storedUserName = await _secureStorage.read(key: 'username');
    if (storedUserName != null) {
      setState(() {
        userName = storedUserName;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Function to show the support dialog
  void showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Need Help?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Divider(height: 0),
              Flexible(
                child: SingleChildScrollView(
                  // Ensures scrolling if needed
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.phone, color: Colors.green),
                        title: const Text("Call"),
                        subtitle: const Text(
                          "Available 24/7",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF848F8B)),
                        ),
                        onTap: () {
                          launchUrl(Uri.parse('tel:+91 9019089955'));
                        },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.green),
                        title: const Text("Email us about an issue"),
                        subtitle: const Text(
                          "8 AM-12 AM IST",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF848F8B)),
                        ),
                        onTap: () {
                          launchUrl(Uri(
                            scheme: 'mailto',
                            path: 'support@meshatech.com',
                            query:
                                'subject=Support Request&body=Please help me with...\n',
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 0),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.transparent),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Confirm Logout",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Content
                Text(
                  "Are you sure you want to log out?",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF848F8B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Full-width Divider
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Divider(
                    height: 0,
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logout Button
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close the dialog
                        // Perform logout logic here
                        await _secureStorage.deleteAll();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.transparent),
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        "LOGOUT",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Center(
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          IntrinsicHeight(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ensures the column takes minimum height
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side: CircleAvatar, Name, User Tag
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CircleAvatar with first 2 letters of the name
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFFECFFF6),
                                child: Text(
                                  userName.substring(0, 2).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Name and User Tag
                              Row(
                                children: [
                                  Text(
                                    "${userName[0].toUpperCase()}${userName.substring(1)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      userTag,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Right side: Data Retrieved
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'No Of Data Retrieved',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              dataRetrieved.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Email and Mobile Number
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$email | $mobileNumber',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          IntrinsicHeight(
              child: Card(
            margin: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  NavigationCard(
                      onTap: () {
                        print("Profile clicked!");
                        Navigator.pushNamed(context, '/my_profile');
                      },
                      title: 'My profile',
                      icon: Icons.person_outlined),
                  const Divider(
                    height: 10,
                    color: Color(0xFFEAEAEA),
                  ),
                  NavigationCard(
                      onTap: () {
                        print("Change Password clicked!");
                        Navigator.pushNamed(context, '/change_password');
                      },
                      title: 'Change Password',
                      icon: Icons.lock_outline),
                  const Divider(
                    height: 10,
                    color: Color(0xFFEAEAEA),
                  ),
                  NavigationCard(
                      onTap: () {
                        print("Support clicked!");
                        showSupportDialog(context);
                      },
                      title: 'Support',
                      icon: Icons.support_agent_outlined),
                  const Divider(
                    height: 10,
                    color: Color(0xFFEAEAEA),
                  ),
                  NavigationCard(
                      onTap: () {
                        print("Logout clicked!");
                        _showLogoutDialog(context);
                      },
                      title: 'Logout',
                      icon: Icons.logout_outlined),
                ],
              ),
            ),
          )),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Center(
                child: Column(
              children: [
                Image.asset(
                  'assets/logo_grey.png',
                  width: 120,
                ),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF848F8B),
                  ),
                ),
              ],
            )),
          )
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}

class NavigationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const NavigationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFECFFF6),
              child: Icon(
                icon,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 18,
            )
          ],
        ),
      ),
    );
  }
}
