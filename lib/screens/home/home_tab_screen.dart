import 'package:bodo_app/screens/saved_items/saved_items_screen.dart';
import 'package:bodo_app/screens/authentication/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import '../post_ad/post_ad_screen.dart';
import '../profile/profile_screen.dart';
import 'package:flutter/services.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PostAdScreen(),
    SavedItemsScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) async {
    if ([1, 2].contains(index)) { 
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          final shouldLogin = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sign in Required'),
              content: const Text('Please sign in to access this feature'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          );

          if (shouldLogin == true) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          }
          return;
        }
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      if (_currentIndex == 0) {
        SystemNavigator.pop();  // This will minimize the app
      } else {
        setState(() {
          _currentIndex = 0;
        });
      }
      return false;  
    },
    child: Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.lightBlueAccent,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(Icons.add_circle_outline, Icons.add_circle, 'Post Ad'),
              _buildNavItem(Icons.bookmark_border, Icons.bookmark, 'Saved'),
              _buildNavItem(Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    ),
  );
}

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}