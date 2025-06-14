import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_first/utlis//ip.dart';

class FetchFDPage extends StatefulWidget {
  final int userId;

  const FetchFDPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<FetchFDPage> createState() => _FetchFDPageState();
}

class _FetchFDPageState extends State<FetchFDPage> {
  List<dynamic> fds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFDs();
  }

  Future<void> fetchFDs() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/user-fds/${widget.userId}"),
    );

    if (response.statusCode == 200) {
      setState(() {
        fds = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load FDs')),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color = status.toLowerCase() == 'active'
        ? Colors.green
        : status.toLowerCase() == 'closed'
        ? Colors.red
        : Colors.grey;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Your Fixed Deposits'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : fds.isEmpty
          ? Center(
        child: Text(
          'No Fixed Deposits found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: fds.length,
        itemBuilder: (context, index) {
          final fd = fds[index];
          final formattedStartDate = DateFormat('dd MMM yyyy')
              .format(DateTime.parse(fd["StartDate"]));
          final formattedMaturityDate = DateFormat('dd MMM yyyy')
              .format(DateTime.parse(fd["MaturityDate"]));

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${fd["Amount"]} @ ${fd["InterestRate"]}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      _buildStatusBadge(fd["Status"]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Tenure: ${fd["TenureMonths"]} months'),
                  Text('Start Date: $formattedStartDate'),
                  Text('Maturity Date: $formattedMaturityDate'),
                  Text(
                    'Maturity Amount: ₹${fd["MaturityAmount"]}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
