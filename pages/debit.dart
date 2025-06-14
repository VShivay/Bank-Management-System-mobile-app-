import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_first/utlis//ip.dart';

class DebitCardWidget extends StatefulWidget {
  final int userId;
  const DebitCardWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _DebitCardWidgetState createState() => _DebitCardWidgetState();
}

class _DebitCardWidgetState extends State<DebitCardWidget> {
  Map<String, dynamic>? debitCard;

  @override
  void initState() {
    super.initState();
    fetchDebitCard();
  }

  Future<void> fetchDebitCard() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/user-debit-card/${widget.userId}"),
    );

    if (response.statusCode == 200) {
      final cards = json.decode(response.body);
      if (cards.isNotEmpty) {
        setState(() {
          debitCard = cards[0];
        });
      }
    } else {
      print("Failed to fetch debit card");
    }
  }

  // Helper method to format card number as '1234 5678 9012 3456'
  String formatCardNumber(String cardNumber) {
    final buffer = StringBuffer();
    for (int i = 0; i < cardNumber.length; i++) {
      buffer.write(cardNumber[i]);
      int next = i + 1;
      if (next % 4 == 0 && next != cardNumber.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (debitCard == null) {
      return Center(child: CircularProgressIndicator());
    }

    final expiryDate = DateFormat('MM/yy').format(DateTime.parse(debitCard!["ExpiryDate"]));
    final formattedCardNumber = formatCardNumber(debitCard!["CardNumber"]);

    return Card(
      color: Colors.indigo[600],
      margin: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      child: Container(
        padding: EdgeInsets.all(20),
        height: 180,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DEBIT CARD", style: TextStyle(color: Colors.white, fontSize: 18)),
            Spacer(),
            Text(formattedCardNumber, style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("CVV: ${debitCard!["CVV"]}", style: TextStyle(color: Colors.white)),
                Text("Exp: $expiryDate", style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 10),
            Text("Status: ${debitCard!["Status"]}", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
