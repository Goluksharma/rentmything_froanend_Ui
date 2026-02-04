import 'package:flutter/material.dart';
import 'dart:async';
import '../routes/app_routes.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool otpSent = false;
  bool otpVerified = false;
  String role = "Customer";

  int _secondsRemaining = 0;
  Timer? _timer;

  bool _obscurePassword = true;

  // Prevent double taps / concurrent sendOtp calls
  bool _isSendingOtp = false;

  void _startOTPTimer() {
    setState(() {
      _secondsRemaining = 120;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    nameController.dispose();
    numberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  bool _validatePassword(String value) {
    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B4B4),
                  ),
                ),
                const SizedBox(height: 30),

                // Name
                TextFormField(
                  controller: nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Name required";
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return "Only letters allowed";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Mobile Number
                TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    counterText: "",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Number required";
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return "Enter valid 10-digit number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email required";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password required";
                    }
                    if (!_validatePassword(value)) {
                      return "Min 8 chars, 1 uppercase, 1 number, 1 special char";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // OTP Section
                if (!otpSent)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4B4),
                      ),
                      // Send OTP
                      onPressed: _isSendingOtp
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isSendingOtp = true;
                                });
                                try {
                                  final msg = await ApiService.sendOtp(
                                    emailController.text.trim(),
                                  );
                                  setState(() {
                                    otpSent = true;
                                  });
                                  _startOTPTimer();
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text(msg)));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                } finally {
                                  // small delay to avoid immediate re-tap even if user taps fast
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );
                                  if (mounted) {
                                    setState(() {
                                      _isSendingOtp = false;
                                    });
                                  }
                                }
                              }
                            },
                      child: _isSendingOtp
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Send OTP"),
                    ),
                  )
                else if (!otpVerified)
                  Column(
                    children: [
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          labelText: "Enter OTP",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "OTP required"
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4B4),
                        ),
                        // Verify OTP
                        onPressed: () async {
                          if (otpController.text.isNotEmpty) {
                            try {
                              final msg = await ApiService.verifyOtp(
                                emailController.text.trim(),
                                otpController.text.trim(),
                              );
                              if (msg.toLowerCase().contains("success")) {
                                setState(() {
                                  otpVerified = true;
                                });
                              }
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(msg)));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: const Text("Verify OTP"),
                      ),
                      const SizedBox(height: 10),
                      if (_secondsRemaining > 0)
                        Text("Resend available in $_secondsRemaining s")
                      else
                        TextButton(
                          // Resend OTP (re-uses sendOtp)
                          onPressed: _isSendingOtp
                              ? null
                              : () async {
                                  // Prevent resend if timer still running (shouldn't be visible) or if already sending
                                  if (_secondsRemaining > 0) return;
                                  setState(() {
                                    _isSendingOtp = true;
                                  });
                                  try {
                                    final msg = await ApiService.sendOtp(
                                      emailController.text.trim(),
                                    );
                                    _startOTPTimer();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    await Future.delayed(
                                      const Duration(milliseconds: 300),
                                    );
                                    if (mounted) {
                                      setState(() {
                                        _isSendingOtp = false;
                                      });
                                    }
                                  }
                                },
                          child: const Text("Resend OTP"),
                        ),
                    ],
                  ),

                const SizedBox(height: 30),

                // Role Selector
                ToggleButtons(
                  isSelected: [role == "Customer", role == "Owner"],
                  onPressed: (index) {
                    setState(() {
                      role = index == 0 ? "Customer" : "Owner";
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Customer"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Owner"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4B4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (!otpVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please verify OTP")),
                          );
                          return;
                        }
                        try {
                          // Call register with named parameters to match ApiService implementation
                          final msg = await ApiService.register(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phoneNumber: numberController.text.trim(),
                            role: role,
                            password: passwordController.text.trim(),
                          );
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                          if (msg.toLowerCase().contains("success")) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const Text(
                  "After registration, please log in to use the services.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(135, 10, 8, 8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
