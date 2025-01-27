import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mesha_bluetooth_data_retrieval/views/change_password.dart';
import 'package:mesha_bluetooth_data_retrieval/views/home_bluetooth.dart';
import 'package:mesha_bluetooth_data_retrieval/views/login.dart';
import 'package:mesha_bluetooth_data_retrieval/views/my_profile.dart';
import 'package:mesha_bluetooth_data_retrieval/views/profile.dart';
import 'package:mesha_bluetooth_data_retrieval/views/reports.dart';
import 'package:mesha_bluetooth_data_retrieval/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00B562), // Customize the seed color
          brightness: Brightness.light, // Use light mode
        ),
        useMaterial3: true,
        // textTheme: Typography.material2021(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              fontSize: 20,
            ),
            backgroundColor: Color(0xFF00B562),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  8.0), // Small border radius for squared corners
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              fontSize: 20,
            ),
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF00B562),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  8.0), // Small border radius for squared corners
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: TextStyle(
              fontSize: 20,
            ),
            foregroundColor: Color(0xFF00B562),
            backgroundColor: Colors.green.shade50,
            side: BorderSide(color: Color(0xFF00B562)),
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(8.0), // Small border radius for squared corners
            // ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('zh'), // Chinese
        Locale('hi'), // Hindi
      ],
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LogIn(),
        '/home': (context) => const BluetoothDeviceManager(),
        '/reports': (context) => const ReportsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/my_profile': (context) => MyProfile(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/test': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Material 3 App',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: const Text('Settings'),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Profile'),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton.icon(
                icon: Icon(Icons.start),
                onPressed: () => {
                      Navigator.pushNamed(context, '/splash'),
                    },
                label: Text('start')),
          ],
        ),
      ),
    );
  }
}
