import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late AnimationController _fadeController; // Controller for fade effect
  bool _showSecondLogo = false;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    // Logo Animation Controller (for zooming and rotating)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    // Fade animation controller (for fade-in and fade-out)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    // Zoom and rotate simultaneously
    _logoScaleAnimation = Tween<double>(begin: 1.0, end: 1.7).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: -30.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Start the logo animation
    _logoController.forward();

    // Reverse the animation after it completes
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _logoController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // Once the reverse animation ends, show the second logo
        setState(() {
          _showSecondLogo = true;
        });

        // Start fading in the second logo
        _fadeController.forward();

        // Verify the auth token
        _verifyAuthToken();
      }
    });
  }

  Future<void> _verifyAuthToken() async {
    try {
      final token = await storage.read(key: 'userToken');
      print(token);

      if (token != null) {
        final map = <String, dynamic>{};
        map['token'] = token;
        final response = await http.post(
          Uri.parse('https://bt.meshaenergy.com/apis/app-users/validate-token'),
          body: map,
        );
        print(response.body);

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          if (responseBody['errFlag'] == 0) {
            // Navigate to the home screen
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            // Navigate to the login screen
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          // Navigate to the login screen
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // Navigate to the login screen
        Navigator.pushReplacementNamed(context, '/login');
        print('No token found');
      }
    } catch (e) {
      print(e);
      // Handle any errors that occur during the HTTP request
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00B562),
              const Color(0x4D1E562D),
            ],
            stops: [0.4, 0.98],
          ),
        ),
        child: Center(
          child: _showSecondLogo
              ? FadeTransition(
                  opacity:
                      _fadeController, // Applying fade effect to second logo
                  child: Image.asset(
                    'assets/logo2.png', // Replace with the second logo
                    width: 350, // Adjust as needed
                  ),
                )
              : AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _logoRotationAnimation.value * 3.1416 / 180,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/logo.png', // Replace with the first logo
                    width: 100, // Adjust as needed
                  ),
                ),
        ),
      ),
    );
  }
}
