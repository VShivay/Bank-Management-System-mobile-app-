import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_first/utlis//ip.dart';



class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedAccountType;
  DateTime? _dob;

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date); // ✅ MySQL expects this format
  }

  Future<void> _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _panController.dispose();
    _aadhaarController.dispose();
    _pinCodeController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Registration')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) =>
                v!.length != 10 ? 'Enter a valid 10-digit number' : null,
              ),
              GestureDetector(
                onTap: _pickDOB,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                    ),
                    controller: TextEditingController(
                      text: _dob != null ? _formatDate(_dob) : '',
                    ),
                    validator: (_) =>
                    _dob == null ? 'Date of Birth is required' : null,
                  ),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (v) => v!.contains('@') ? null : 'Invalid email',
              ),
              TextFormField(
                controller: _panController,
                decoration: InputDecoration(labelText: 'PAN Card Number'),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) => !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$')
                    .hasMatch(v!.toUpperCase())
                    ? 'Invalid PAN format'
                    : null,
              ),
              TextFormField(
                controller: _aadhaarController,
                decoration: InputDecoration(labelText: 'Aadhaar Number'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (v) =>
                v!.length != 12 ? 'Aadhaar must be 12 digits' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Address required' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (v) => v!.isEmpty ? 'City required' : null,
              ),
              TextFormField(
                controller: _pinCodeController,
                decoration: InputDecoration(labelText: 'Pin Code'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (v) =>
                v!.length != 6 ? 'Pin Code must be 6 digits' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                v!.length < 6 ? 'Password must be 6+ characters' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedAccountType,
                decoration: InputDecoration(labelText: 'Account Type'),
                items: ['Saving', 'Current']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedAccountType = val;
                }),
                validator: (v) =>
                v == null ? 'Please select account type' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Register'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final formData = {
                      "name": _nameController.text.trim(),
                      "mobileNumber": _mobileController.text.trim(),
                      "dob": _formatDate(_dob),
                      "email": _emailController.text.trim(),
                      "panCardNumber":
                      _panController.text.trim().toUpperCase(),
                      "aadhaarNumber": _aadhaarController.text.trim(),
                      "address": _addressController.text.trim(),
                      "city": _cityController.text.trim(),
                      "pinCode": _pinCodeController.text.trim(),
                      "password": _passwordController.text.trim(),
                      "acc_type": _selectedAccountType,
                    };

                    final url = Uri.parse('$baseUrl/api/apply');
                    try {
                      final res = await http.post(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(formData),
                      );

                      if (res.statusCode == 200 || res.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Success!')),
                        );
                      } else {
                        print('Error: ${res.body}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: ${res.body}')),
                        );
                      }
                    } catch (e) {
                      print('Exception: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Network error: $e')),
                      );
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
