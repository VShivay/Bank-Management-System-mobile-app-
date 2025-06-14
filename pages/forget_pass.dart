import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_first/utlis//ip.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isVerified = false;
  String message = '';
  int? userId;
  bool obscureText = true;

  final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
  String passwordHint = '';

  void validatePassword(String password) {
    List<String> issues = [];

    if (password.length < 8) issues.add("Min 8 chars");
    if (!RegExp(r'[A-Z]').hasMatch(password)) issues.add("1 uppercase");
    if (!RegExp(r'\d').hasMatch(password)) issues.add("1 number");
    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) issues.add("1 special");

    setState(() {
      passwordHint = issues.isEmpty ? "Strong password ✅" : "Needs: ${issues.join(', ')}";
    });
  }

  Future<void> verifyIdentifier() async {
    final identifier = identifierController.text.trim();
    if (identifier.isEmpty) {
      setState(() => message = "Please enter your account/mobile/Aadhaar/card number.");
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    final url = Uri.parse("$baseUrl/api/verify-identifier");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identifier': identifier}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['userId'] != null) {
        setState(() {
          userId = data['userId'];
          isVerified = true;
          message = "User verified. Please enter new password.";
        });
      } else {
        setState(() => message = data['error'] ?? "Verification failed");
      }
    } catch (e) {
      setState(() => message = "Error connecting to server.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> setNewPassword() async {
    final password = passwordController.text.trim();

    if (!passwordRegex.hasMatch(password)) {
      setState(() {
        message = "Password must have 8+ chars, 1 uppercase, 1 number, 1 special.";
      });
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("$baseUrl/api/set-new-password");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'newPassword': password}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          message = "Password reset successful.";
          isVerified = false;
          passwordController.clear();
          identifierController.clear();
        });
      } else {
        setState(() => message = data['error'] ?? "Failed to reset password");
      }
    } catch (e) {
      setState(() => message = "Server error.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: identifierController,
              decoration: InputDecoration(
                labelText: 'Enter Account/Mobile/Aadhaar/Card Number',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            if (!isVerified)
              ElevatedButton(
                onPressed: isLoading ? null : verifyIdentifier,
                child: isLoading ? CircularProgressIndicator() : Text("Verify"),
              ),
            if (isVerified) ...[
              TextField(
                controller: passwordController,
                obscureText: obscureText,
                onChanged: validatePassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => obscureText = !obscureText),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  passwordHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: passwordHint.contains("✅") ? Colors.green : Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : setNewPassword,
                child: Text("Set New Password"),
              ),
            ],
            SizedBox(height: 20),
            if (message.isNotEmpty)
              Text(
                message,
                style: TextStyle(
                  color: message.contains("successful") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
