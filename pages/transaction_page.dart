import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:my_first/utlis//ip.dart';

class TransactionPage extends StatefulWidget {
  final int userId;

  TransactionPage({required this.userId});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isLoading = true;
  List transactions = [];
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = data['transactions'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load transactions';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error connecting to server';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transactions')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : transactions.isEmpty
          ? Center(child: Text('No transactions found'))
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          DateTime dateTime = DateTime.tryParse(tx['Timestamp']) ?? DateTime.now();
          String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

          return ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text('${tx['TransactionType']} - ₹${tx['Amount']}'),
            subtitle: Text('On: $formattedDate'),
            trailing: tx['RecipientAccountID'] != null
                ? Text('To Acc: ${tx['RecipientAccountID']}')
                : null,
          );
        },
      ),
    );
  }
}
