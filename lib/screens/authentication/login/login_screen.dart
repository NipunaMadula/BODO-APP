import 'package:bodo_app/blocs/auth/auth_bloc.dart';
import 'package:bodo_app/blocs/auth/auth_event.dart';
import 'package:bodo_app/blocs/auth/auth_state.dart';
import 'package:bodo_app/repositories/auth_repository.dart';
import 'package:bodo_app/utils/form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bodo_app/screens/home/home_tab_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return BlocListener<AuthBloc, AuthState>( 
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeTabScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: TextStyle(fontSize: screenWidth * 0.035),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: screenWidth * 0.06,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'BODO APP',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: screenWidth * 0.1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.045),
                  
                  Text(
                    'Welcome back! Glad\nto see you, Again!',
                    style: TextStyle(
                      fontSize: screenWidth * 0.075,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.045),
                  
                  TextFormField(
                    controller: _emailController,
                    validator: FormValidators.validateEmail,
                    style: TextStyle(fontSize: screenWidth * 0.04),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(screenWidth * 0.05),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: screenWidth * 0.04),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(screenWidth * 0.05),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                          size: screenWidth * 0.06,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                LoginRequested(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.08),
                            ),
                            elevation: 0,
                          ),
                          child: state is AuthLoading
                              ? SizedBox(
                                  height: screenWidth * 0.05,
                                  width: screenWidth * 0.05,
                                  child: const CircularProgressIndicator(color: Colors.white),
                                )
                              : Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.035),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                        child: Text(
                          'Or',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.025),
                  
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        onTap: () {
                          context.read<AuthBloc>().add(GoogleSignInRequested());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google_logo.png',
                              height: screenWidth * 0.06,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              'Log In with Google',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.035),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          '  Register',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}