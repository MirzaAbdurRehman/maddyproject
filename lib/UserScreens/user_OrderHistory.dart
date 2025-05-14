import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserOrderHistoryTab extends StatefulWidget {
  @override
  State<UserOrderHistoryTab> createState() => _UserOrderHistoryTabState();
}

class _UserOrderHistoryTabState extends State<UserOrderHistoryTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getUserEmail();
  }

  Future<void> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    if (email != null) {
      setState(() {
        userId = email;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Orders History", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            OrderListWidget(
              collectionName: 'AddOrderData',
              userId: userId,
              statusColor: Colors.orange,
              label: 'Pending',
            ),
            OrderListWidget(
              collectionName: 'acceptorder',
              userId: userId,
              statusColor: Colors.green,
              label: 'Accepted',
            ),
            OrderListWidget(
              collectionName: 'rejectorder',
              userId: userId,
              statusColor: Colors.red,
              label: 'Rejected',
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable order card widget
class OrderListWidget extends StatelessWidget {
  final String collectionName;
  final String userId;
  final Color statusColor;
  final String label;

  OrderListWidget({
    required this.collectionName,
    required this.userId,
    required this.statusColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .where('userID', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Something went wrong!'));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text('No $label Orders Found'));

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            return OrderCard(data: data, statusColor: statusColor, label: label);
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot data;
  final Color statusColor;
  final String label;

  OrderCard({required this.data, required this.statusColor, required this.label});

  @override
  Widget build(BuildContext context) {
    String productName = data['productName'];
    String productImage = data['productImage'];
    String totalPrice = data['total_price'].toString();
    int quantity = data['productQuantity'];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                productImage,
                height: 100,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("Total Price: ₹$totalPrice", style: TextStyle(color: Colors.red)),
                  Text("Quantity: $quantity"),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: statusColor),
                      SizedBox(width: 6),
                      Text(label, style: TextStyle(color: statusColor)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
