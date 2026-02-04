// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AddServicePage extends StatefulWidget {
  final User user;
  const AddServicePage({super.key, required this.user});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  String title = "";
  String description = "";
  double price = 0.0;
  String address = "";
  String? selectedCategory;
  List<String> categories = [];
  bool _isSubmitting = false; // ✅ loading flag

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

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    try {
      final msg = await ApiService.addService(
        email: widget.user.email,
        role: widget.user.role, // ✅ send role
        title: title,
        description: description,
        price: price,
        address: address,
        category: selectedCategory ?? "ANY",
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // ✅ Reset form after success
      _formKey.currentState!.reset();
      setState(() {
        title = "";
        description = "";
        price = 0.0;
        address = "";
        selectedCategory = null;
      });

      Navigator.pop(context, true); // ✅ return true so parent can refresh
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add service: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Service")),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter a title" : null,
                  onSaved: (val) => title = val!,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter description" : null,
                  onSaved: (val) => description = val!,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter price";
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed <= 0) {
                      return "Price must be greater than 0";
                    }
                    return null;
                  },
                  onSaved: (val) => price = double.tryParse(val!) ?? 0.0,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Address"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter address" : null,
                  onSaved: (val) => address = val!,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedCategory = val),
                  decoration: const InputDecoration(labelText: "Category"),
                  validator: (val) =>
                      val == null ? "Please select a category" : null,
                ),
                const SizedBox(height: 30),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _submitService,
                        child: const Text("Submit Service"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
