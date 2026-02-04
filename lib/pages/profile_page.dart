import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart'; // for SystemNavigator.pop
import 'package:ui_rentmything/pages/AddServicePage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  const ProfilePage({super.key, required this.user});

  Future<void> _saveLocation(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final msg = await ApiService.saveLocation(
        email: user.email,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save location: $e")));
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final msg = await ApiService.deleteAccount(user.email);

      await storage.deleteAll();
      await ApiService.clearToken();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      SystemNavigator.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete account: $e")));
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteAccount(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF00B4B4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF00B4B4),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF00B4B4)),
                title: Text(user.email, style: const TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4B4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text(
                  "Save Location",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () => _saveLocation(context),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ OWNER role: Add Services button
            if (user.role.toUpperCase() == "OWNER") ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_business, color: Colors.white),
                  label: const Text(
                    "Add Services",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => AddServicePage(user: user),
                      ),
                    ).then((result) {
                      if (result == true) {
                        // ✅ bubble up to HomePage so it refreshes
                        Navigator.pop(context, true);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  "Delete Account",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () => _confirmDeleteAccount(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
