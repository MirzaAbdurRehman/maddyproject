import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Admin_OrderHistory extends StatefulWidget {
  @override
  State<Admin_OrderHistory> createState() => _Admin_OrderHistoryState();
}

class _Admin_OrderHistoryState extends State<Admin_OrderHistory> {
  String? loadingOrderId; // Track current loading order's document ID
  String? loadingButton; // Track whether 'accept' or 'reject'

  Future<void> handleOrderAction(
      DocumentSnapshot orderDoc, String targetCollection, String actionType) async {
    setState(() {
      loadingOrderId = orderDoc.id;
      loadingButton = actionType; // "accept" or "reject"
    });

    try {
      await FirebaseFirestore.instance
          .collection(targetCollection)
          .add(orderDoc.data() as Map<String, dynamic>);

      await FirebaseFirestore.instance
          .collection('AddOrderData')
          .doc(orderDoc.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order ${actionType == "accept" ? "accepted" : "rejected"} successfully!'),
        backgroundColor: actionType == "accept" ? Colors.green : Colors.red,
      ));
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        loadingOrderId = null;
        loadingButton = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('AddOrderData').snapshots(),
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
                  elevation: 3,
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
                              Text("Total Price: $totalPrice Rs.", style: TextStyle(color: Colors.red)),
                              Text("Quantity: $quantity"),
                              Text("User Email: $userId", style: TextStyle(color: Colors.blue)),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: (loadingOrderId == data.id && loadingButton == 'accept')
                                          ? null
                                          : () => handleOrderAction(data, 'acceptorder', 'accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: (loadingOrderId == data.id && loadingButton == 'accept')
                                          ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                          : Text("Accept", style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: (loadingOrderId == data.id && loadingButton == 'reject')
                                          ? null
                                          : () => handleOrderAction(data, 'rejectorder', 'reject'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: (loadingOrderId == data.id && loadingButton == 'reject')
                                          ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                          : Text("Reject", style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              )
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
