// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';

class MainLayout extends StatefulWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? userData;

  const MainLayout({super.key, required this.isLoggedIn, this.userData});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (widget.isLoggedIn && index == 2) {
      _showLogoutDialog();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4B4),
            ),
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(ctx);

              try {
                // ✅ Clear local stored token only (no server call)
                await ApiService.clearToken();

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully")),
                );

                // Navigate back to home
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              } catch (e) {
                // If clearing token failed, show error
                final error = e.toString().replaceFirst('Exception: ', '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logout failed: $error")),
                );
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.isLoggedIn
        ? [
            HomePage(userData: widget.userData),
            const Center(child: Text("Help Page")),
            const SizedBox(), // logout placeholder
          ]
        : [HomePage(), LoginPage(), RegisterPage()];

    const Color themeColor = Color(0xFF00B4B4);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F7FF),
      appBar: AppBar(
        title: const Text("RentMything"),
        backgroundColor: themeColor,
        automaticallyImplyLeading: false,
        actions: widget.isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.person, size: 30),
                  tooltip: "Profile",
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.profile,
                      arguments: widget.userData,
                    );
                  },
                ),
              ]
            : null,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: themeColor,
        items: widget.isLoggedIn
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Help'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Logout',
                ),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.login),
                  label: 'Login',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.app_registration),
                  label: 'Register',
                ),
              ],
      ),
    );
  }
}
