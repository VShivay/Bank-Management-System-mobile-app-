import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_first/utlis//ip.dart';

class CreateFDPage extends StatefulWidget {
  final int userId;
  final int accountId;

  const CreateFDPage({required this.userId, required this.accountId});

  @override
  _CreateFDPageState createState() => _CreateFDPageState();
}

class _CreateFDPageState extends State<CreateFDPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _tenureController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  Future<void> createFD() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/create-fd'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': widget.userId,
        'accountId': widget.accountId,
        'amount': double.tryParse(_amountController.text.trim()),
        'tenureMonths': int.tryParse(_tenureController.text.trim()),
      }),
    );

    final data = json.decode(response.body);
    setState(() {
      _isLoading = false;
      _message = data['message'] ?? 'Unknown error';
    });

    if (response.statusCode == 200) {
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Create Fixed Deposit'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.lock, size: 40, color: Colors.deepPurple),
                  SizedBox(height: 10),
                  Text(
                    'Open a New FD',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 30),

                  /// Amount Field
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || double.tryParse(value) == null)
                        ? 'Enter valid amount'
                        : null,
                  ),
                  SizedBox(height: 20),

                  /// Tenure Field
                  TextFormField(
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tenure (Months)',
                      prefixIcon: Icon(Icons.calendar_month),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || int.tryParse(value) == null)
                        ? 'Enter valid tenure'
                        : null,
                  ),
                  SizedBox(height: 30),

                  /// Create FD Button
                  _isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.check_circle),
                            label: Text(
                              'Create FD',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: createFD,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                  SizedBox(height: 20),

                  /// Message Display
                  if (_message.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _message.contains('success')
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _message.contains('success')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _message.contains('success')
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
