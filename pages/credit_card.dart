import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_first/utlis//ip.dart';

class CreditCardScreen extends StatefulWidget {
  final int userID;

  CreditCardScreen({required this.userID});

  @override
  _CreditCardScreenState createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  bool isLoading = true;
  bool alreadyApplied = false;
  Map<String, dynamic>? cardDetails;

  @override
  void initState() {
    super.initState();
    checkCreditCardStatus();
  }

  Future<void> checkCreditCardStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/credit-card/${widget.userID}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          cardDetails = jsonDecode(response.body);
          alreadyApplied = true;
          isLoading = false;
        });
      } else {
        setState(() {
          alreadyApplied = false;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> applyForCreditCard() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/apply-credit-card'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': widget.userID}),
    );

    if (response.statusCode == 201) {
      await checkCreditCardStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credit card application submitted.')),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${jsonDecode(response.body)['message'] ?? "Something went wrong"}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Credit Card")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: alreadyApplied
            ? cardDetails != null
            ? buildCardDetails()
            : Center(child: Text("No credit card details found."))
            : Center(
          child: ElevatedButton(
            onPressed: applyForCreditCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(
                  horizontal: 30, vertical: 16),
              textStyle: TextStyle(fontSize: 16),
            ),
            child: Text("Apply for Credit Card"),
          ),
        ),
      ),
    );
  }

  Widget buildCardDetails() {
    final expiryRaw = cardDetails!['ExpiryDate'];
    DateTime? expiryDate;
    String formattedExpiry = "N/A";
    if (expiryRaw != null) {
      try {
        expiryDate = DateTime.parse(expiryRaw);
        formattedExpiry = DateFormat('MM/yy').format(expiryDate);
      } catch (e) {
        print("Invalid expiry date format");
      }
    }

    final outstanding = double.tryParse(cardDetails!['CurrentOutstanding'] ?? '0') ?? 0.0;
    final limit = double.tryParse(cardDetails!['CardLimit'] ?? '1') ?? 1.0;
    final progress = (outstanding / limit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You have already applied for a credit card.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.shade200.withOpacity(0.6),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Credit Card", style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 12),
              Text(
                formatCardNumber(cardDetails!['CardNumber'] ?? ''),
                style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 3, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Expiry: $formattedExpiry", style: TextStyle(color: Colors.white70)),
                  Text("CVV: ${cardDetails!['CVV'] ?? '***'}", style: TextStyle(color: Colors.white70)),
                ],
              ),
              SizedBox(height: 24),
              Text("Status: ${cardDetails!['Status'] ?? 'Unknown'}", style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 24),
              Text("Credit Limit: ₹${cardDetails!['CardLimit'] ?? '0'}", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text(
                "Outstanding: ₹${cardDetails!['CurrentOutstanding'] ?? '0'}",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  minHeight: 16,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                  value: progress,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("0", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("₹${cardDetails!['CardLimit'] ?? '0'}", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String formatCardNumber(String cardNumber) {
  final buffer = StringBuffer();
  for (int i = 0; i < cardNumber.length; i++) {
    buffer.write(cardNumber[i]);
    final next = i + 1;
    if (next % 4 == 0 && next != cardNumber.length) buffer.write('  ');
  }
  return buffer.toString();
}
