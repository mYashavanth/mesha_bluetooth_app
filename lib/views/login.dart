import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LogInContent(),
      ),
    );
  }
}

class LogInContent extends StatelessWidget {
  const LogInContent({super.key});

  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0, // Adjusted for drag handle placement
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              // Drag Handle
              Container(
                width: 80, // Increased width
                height: 6, // Standard drag handle height
                decoration: BoxDecoration(
                  color: Colors.black26, // Light gray with glass effect
                  borderRadius: BorderRadius.circular(3), // Rounded corners
                ),
              ),
              const SizedBox(height: 10), // Spacing below drag handle
              // Login Form
              LoginForm(),
            ],
          ),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stack for image and logo
        Stack(
          children: [
            Container(
              height: 360,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/login_page_img.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Image.asset(
                'assets/login_page_logo.png',
                height: 69,
                width: 120,
              ),
            ),
          ],
        ),

        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Empowering Data,\nSimplified',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your data, just a tap away!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),

        const Expanded(child: SizedBox()),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Ready to take control?',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(50, 56, 54, 1),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    _showLoginBottomSheet(context);
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}




class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    // Email regex validation
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  List<String> _validatePassword(String? value) {
    List<String> errors = [];

    if (value == null || value.isEmpty) {
      errors.add('Password cannot be empty');
    }
    if (value != null && value.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }
    if (value != null && !RegExp(r'[A-Z]').hasMatch(value)) {
      errors.add('Password must include at least one uppercase letter');
    }
    if (value != null && !RegExp(r'[a-z]').hasMatch(value)) {
      errors.add('Password must include at least one lowercase letter');
    }
    if (value != null && !RegExp(r'[0-9]').hasMatch(value)) {
      errors.add('Password must include at least one number');
    }
    if (value != null && !RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      errors.add('Password must include at least one special character');
    }

    return errors;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      print('Email: ${_usernameController.text}');
      print('Password: ${_passwordController.text}');
      Navigator.pop(context);
      Navigator.pushNamed(context, '/navigation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sign in to your account!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Email',
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
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress, // Use email keyboard
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
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
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              List<String> errors = _validatePassword(value);
              if (errors.isNotEmpty) {
                return errors.join('\n');
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot password?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _handleSubmit,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

