import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class OwnerHomePage extends StatefulWidget {
  final User user;
  const OwnerHomePage({super.key, required this.user});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage>
    with WidgetsBindingObserver {
  List<dynamic> ownerItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ listen for lifecycle changes
    _loadOwnerProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ Called when app/page resumes (e.g. after popping back from AddServicePage)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadOwnerProfile();
    }
  }

  Future<void> _loadOwnerProfile() async {
    try {
      final profile = await ApiService.fetchOwnerProfile(
        email: widget.user.email,
        role: widget.user.role,
      );
      setState(() {
        ownerItems = profile['items'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load services: $e")));
    }
  }

  Future<void> _deleteService(String title) async {
    try {
      await ApiService.deleteItem(email: widget.user.email, title: title);
      await _loadOwnerProfile(); // ✅ reload from backend after delete
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete service: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadOwnerProfile, // ✅ swipe down to refresh
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Your Services",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          if (ownerItems.isEmpty)
            const Center(child: Text("No services registered yet."))
          else
            ...ownerItems.map((service) {
              return Card(
                child: ListTile(
                  title: Text(service['title'] ?? 'Untitled'),
                  subtitle: Text(
                    "₹${service['price']} • ${service['category']}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteService(service['title']),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
