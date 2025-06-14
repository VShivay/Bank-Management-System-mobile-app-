import 'package:flutter/material.dart';
import 'transfer_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'transaction_page.dart';
import 'package:my_first/pages/login_page.dart';
import 'create_fd_page.dart';
import 'fetch_fd_page.dart';
import 'debit.dart';
import 'package:intl/intl.dart';
import 'credit_card.dart';
import 'package:my_first/utlis//ip.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  DashboardPage({required this.user});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool showDetails = false;
  double balance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("User data: ${widget.user}");
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    final userId = widget.user['id'];

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/balance/$userId"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          balance = double.parse(data['balance']);
          isLoading = false;
          print(balance);
        });
      } else {
        print("Failed to fetch balance");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching balance: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final ai = user['dob'];
    final formattedDob = DateFormat('dd MMM yyyy').format(DateTime.parse(ai));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Welcome, ${user['name']}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.black), // Set icon color to black
            tooltip: 'Transactions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionPage(userId: user['id']),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black), // Set icon color to black
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            /// Balance Card
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Balance', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            /// Debit Card Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Debit Card", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 10),
                DebitCardWidget(userId: user['id']),
              ],
            ),

            SizedBox(height: 20),

            /// Action Buttons
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(Icons.compare_arrows, "Transfer Funds", () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransferFundsPage(userId: user['id'], accountId: user['accountId']),
                    ),
                  );
                  fetchBalance();
                }),
                _buildActionButton(Icons.account_balance, "Create FD", () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateFDPage(userId: user['id'], accountId: user['accountId']),
                    ),
                  );
                  fetchBalance();
                }),
                _buildActionButton(Icons.savings, "Check FD", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FetchFDPage(userId: user['id'])),
                  );
                }),
                _buildActionButton(Icons.credit_card, "Credit Card", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreditCardScreen(userID: user['id'])),
                  );
                }),
              ],
            ),

            SizedBox(height: 20),

            /// User Details
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ExpansionTile(
                title: Text('User Details', style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  ListTile(title: Text('User ID: ${user['id']}')),
                  ListTile(title: Text('Mobile Number: ${user['mobile']}')),
                  ListTile(title: Text('Email: ${user['email']}')),
                  ListTile(title: Text('Date of Birth: $formattedDob')),
                  ListTile(title: Text('Address: ${user['address']}')),
                  ListTile(title: Text('City: ${user['city']}')),
                  ListTile(title: Text('Pin Code: ${user['pinCode']}')),
                  ListTile(title: Text('PAN Card: ${user['panCardNumber']}')),
                  ListTile(title: Text('Aadhaar Number: ${user['aadhaarNumber']}')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Stylish Action Button
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: TextStyle(fontSize: 14, color: Colors.black), // <-- TEXT COLOR BLACK
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.deepPurple.shade400, // Optional: light background for contrast
        elevation: 3,
      ),
      onPressed: onTap,
    );
  }


}
