import 'package:bodo_app/screens/authentication/login/login_screen.dart';
import 'package:bodo_app/screens/profile/about_us_screen.dart';
import 'package:bodo_app/screens/profile/help_center_screen.dart';
import 'package:bodo_app/screens/profile/my_properties_screen.dart';
import 'package:bodo_app/screens/profile/personal_information_screen.dart';
import 'package:bodo_app/screens/profile/privacy_policy_screen.dart';
import 'package:bodo_app/screens/profile/user_reviews_screen.dart';
import 'package:bodo_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          if (mounted) {
            setState(() {
              _userModel = UserModel.fromFirestore(doc);
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        print('Error loading user data: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToPersonalInfo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PersonalInformationScreen()),
    );
    
    if (mounted) {
      setState(() => _isLoading = true);
      await _loadUserData();
    }
  }

Future<void> _handleLogout(BuildContext context) async {
  // Show confirmation dialog
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (shouldLogout == true) {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
       automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Image
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.person_outline,
                          size: 45,
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name
                    Text(
                      _userModel?.name ?? 'Please verify your account',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Profile Actions
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.person_outline,
                            title: 'Personal Information',
                            onTap: _navigateToPersonalInfo,
                          ),
                          _buildDivider(),
                          _buildListTile(
                            icon: Icons.villa,
                            title: 'My Properties',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MyPropertiesScreen()),
                            ),
                          ),
                          _buildDivider(),
                          _buildListTile(
                            icon: Icons.star_outline,
                            title: 'My Reviews',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const UserReviewsScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Support Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            icon: Icons.help_outline,
                            title: 'Help Center',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                            ),
                          ),
                          _buildDivider(),
                          _buildListTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                            ),
                          ),
                          _buildDivider(),
                          _buildListTile(
                            icon: Icons.info_outline,
                            title: 'About Us',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    TextButton(
                      onPressed: () => _handleLogout(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade400, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }
}