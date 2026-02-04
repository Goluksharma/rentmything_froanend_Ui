import 'package:flutter/material.dart';
import '../models/user.dart';
import 'customer_home_page.dart';
import 'owner_home_page.dart';

class HomePage extends StatelessWidget {
  final User? user;
  final Map<String, dynamic>? userData;

  HomePage({super.key, this.userData})
    : user = userData != null ? User.fromMap(userData) : null;

  @override
  Widget build(BuildContext context) {
    final String role = user?.role ?? 'Visitor';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 246, 246),
        elevation: 0,
      ),
      body: user == null
          // ✅ Show landing page with ads if not logged in
          ? SingleChildScrollView(
              child: Column(
                children: [
                  // Hero banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.teal.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          "Welcome to RentMyThing",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Easily rent, share, and discover items around you.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Feature cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildFeatureCard(
                          icon: Icons.shopping_cart,
                          title: "Browse Items",
                          description:
                              "Find essentials, tools, and unique items available for rent near you.",
                        ),
                        _buildFeatureCard(
                          icon: Icons.add_business,
                          title: "List Your Services",
                          description:
                              "Owners can easily add services or items to share and earn money.",
                        ),
                        _buildFeatureCard(
                          icon: Icons.location_on,
                          title: "Location Based",
                          description:
                              "Discover items and services based on your saved location.",
                        ),
                        _buildFeatureCard(
                          icon: Icons.security,
                          title: "Secure & Reliable",
                          description:
                              "Safe transactions and trusted community to give you peace of mind.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          // ✅ Show role-based dashboard if logged in
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: role.toUpperCase() == "CUSTOMER"
                        ? CustomerHomePage(user: user!)
                        : role.toUpperCase() == "OWNER"
                        ? OwnerHomePage(user: user!)
                        : const Center(child: Text("Unknown role")),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper widget for feature cards
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
