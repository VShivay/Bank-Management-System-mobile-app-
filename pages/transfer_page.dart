import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_first/utlis//ip.dart';

class TransferFundsPage extends StatefulWidget {
  final int userId;
  final int accountId;

  TransferFundsPage({required this.userId, required this.accountId});

  @override
  _TransferFundsPageState createState() => _TransferFundsPageState();
}

class _TransferFundsPageState extends State<TransferFundsPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> transferFunds() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'senderAccountId': widget.accountId,
        'recipientAccountNumber': _recipientController.text.trim(),
        'amount': double.tryParse(_amountController.text.trim()),
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
      appBar: AppBar(
        title: Text('Transfer Funds'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.send, size: 40, color: Colors.deepPurple),
                  SizedBox(height: 10),
                  Text(
                    'Send Money Securely',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 30),

                  /// Recipient Account Field
                  TextFormField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      labelText: 'Recipient Account Number',
                      prefixIcon: Icon(Icons.account_balance),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter account number'
                        : null,
                  ),
                  SizedBox(height: 20),

                  /// Amount Field
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid amount greater than 0';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  /// Submit Button
                  _isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: transferFunds,
                      icon: Icon(Icons.send),
                      label: Text('Transfer'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  /// Message Display
                  if (_message.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _message.contains('success') ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _message.contains('success') ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _message.contains('success') ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
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
