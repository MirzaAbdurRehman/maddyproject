import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User_OrderHistory extends StatefulWidget {
  @override
  State<User_OrderHistory> createState() => _User_OrderHistoryState();
}

class _User_OrderHistoryState extends State<User_OrderHistory> {

  String user_id = '';

  Future<void> getUserEmail() async {
    SharedPreferences userCred = await SharedPreferences.getInstance();
    String? email = userCred.getString("email");
    if (email != null) {
      setState(() {
        user_id = email;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }


  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
        title: Text(
          "Orders History",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('AddOrderData').where('userID', isEqualTo: user_id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Something went wrong!'));

          if (snapshot.hasData) {
            var docs = snapshot.data!.docs;
            if (docs.isEmpty) return Center(child: Text('No Orders Found'));

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var data = docs[index];
                String productName = data['productName'];
                String productImage = data['productImage'];
                String totalPrice = data['total_price'].toString();
                int quantity = data['productQuantity'];
                String userId = data['userID'];

                return Card(
                  elevation: 0,
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
                              Text(
                                productName,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 6),
                              Text("Total Price: $totalPrice Rs." , style: TextStyle(color: Colors.red)),
                              Text("Quantity: $quantity"),

                              SizedBox(height: 10),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return Center(child: Text('No Data Available'));
        },
      ),
    );
  }
}
