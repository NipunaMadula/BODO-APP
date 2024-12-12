import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.06), // Responsive top spacing

            Container(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              width: double.infinity,
              child: Text(
                'BODO APP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  // Responsive font size based on screen width
                  fontSize: screenWidth * 0.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),

            const Spacer(flex: 1),

            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Image.asset(
                'assets/main_logo.jpg',
                // Responsive height based on screen height
                height: screenHeight * 0.25,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: screenHeight * 0.07),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                children: [
                  Text(
                    'BOARDING ACCOMADATION FINDER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // Responsive font sizes
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Assists users in finding economical accommodations near their workplace or educational institution',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.blueGrey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            const Spacer(flex: 1),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    // Responsive button width and height
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.08),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.08),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.06),
          ],
        ),
      ),
    );
  }
}