import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 60),
          
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              width: double.infinity,
              child: const Text(
                'BODO APP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2, 
                ),
              ),
            ),
            
            const Expanded(
              child: Center(
                child: Text('Sign Up Form'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}