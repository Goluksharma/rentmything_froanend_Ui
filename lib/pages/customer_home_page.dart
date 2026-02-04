import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ for WhatsApp & Maps
import '../models/user.dart';
import '../services/api_service.dart';

class CustomerHomePage extends StatefulWidget {
  final User user;
  const CustomerHomePage({super.key, required this.user});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  double radius = 5.0;
  String? selectedCategory;
  List<String> categories = [];
  List<dynamic> searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.getCategories();
      setState(() {
        categories = cats;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load categories: $e")));
    }
  }

  Future<void> _performSearch() async {
    try {
      final results = await ApiService.searchOwners(
        email: widget.user.email,
        role: widget.user.role,
        category: selectedCategory ?? "ANY",
        radius: radius,
      );
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Search failed: $e")));
    }
  }

  // ✅ WhatsApp launcher
  Future<void> _openWhatsApp(String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
    }
  }

  // ✅ Google Maps launcher
  Future<void> _openMap(double lat, double lng) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Search Renting Things Near You",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        TextField(
          decoration: const InputDecoration(
            labelText: "Radius (km)",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            radius = double.tryParse(val) ?? 5.0;
          },
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedCategory = val;
            });
          },
          decoration: const InputDecoration(
            labelText: "Select Category",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text("Search"),
            onPressed: _performSearch,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: searchResults.isEmpty
              ? const Center(child: Text("No results yet."))
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final u = searchResults[index];
                    final items = u['items'] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Owner info
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.teal,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    u['name'] ?? "Unknown",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(u['phoneNumber'] ?? "Not provided"),
                                const Spacer(),
                                if (u['phoneNumber'] != null)
                                  IconButton(
                                    icon: Image.asset(
                                      "assets/images/w.png", // ✅ real WhatsApp icon (add to assets)
                                      height: 24,
                                    ),
                                    onPressed: () =>
                                        _openWhatsApp(u['phoneNumber']),
                                  ),
                              ],
                            ),
                            if (u['email'] != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(u['email']),
                                ],
                              ),
                            ],
                            if (u['role'] != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.badge,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text("Role: ${u['role']}"),
                                ],
                              ),
                            ],
                            if (u['latitude'] != null &&
                                u['longitude'] != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Lat: ${u['latitude']}, Lng: ${u['longitude']}",
                                    ),
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      "assets/images/google-map.png", // ✅ real Google Maps icon (add to assets)
                                      height: 24,
                                    ),
                                    onPressed: () =>
                                        _openMap(u['latitude'], u['longitude']),
                                  ),
                                ],
                              ),
                            ],

                            // ✅ Items list
                            if (items.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                "Items:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...items.map<Widget>((item) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? "Untitled",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (item['description'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            "Description: ${item['description']}",
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        if (item['category'] != null)
                                          Text("Category: ${item['category']}"),
                                        if (item['price'] != null)
                                          Text("Price: ₹${item['price']}"),
                                        if (item['address'] != null)
                                          Text("Address: ${item['address']}"),
                                        if (item['email'] != null)
                                          Text("Email: ${item['email']}"),
                                        if (item['role'] != null)
                                          Text("Role: ${item['role']}"),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
