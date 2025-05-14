import 'package:clothing/UserScreens/success.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cartProviderModel/GlobalCart.dart';

class CartItem {
  final String pid;
  final String name;
  final String image;
  final int price;
  final int quantity;

  CartItem({
    required this.pid,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'pid': pid,
      'userID': userId,
      'total_price': price,
      'productName': name,
      'productImage': image,
      'productQuantity': quantity,
    };
  }
}

class CheckOut extends StatelessWidget {
  final String userId;
  final List<CartItem> cartItems;

  const CheckOut({Key? key, required this.userId, required this.cartItems})
      : super(key: key);

  // void submitOrder(BuildContext context) async {
  //   final collection = FirebaseFirestore.instance.collection('AddOrderData');
  //   for (var item in cartItems) {
  //     await collection.add(item.toMap(userId));
  //   }
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Order submitted successfully')),
  //   );
  //
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => SuccessfulScreen()),
  //   );
  // }


  void submitOrder(BuildContext context) async {
    final orderCollection = FirebaseFirestore.instance.collection('AddOrderData');
    final cartCollection = FirebaseFirestore.instance.collection('AddtoCartData');

    try {
      // Add order to 'AddOrderData'
      for (var item in cartItems) {
        await orderCollection.add(item.toMap(userId));
      }

      // Delete all user's cart items from 'AddtoCartData'
      final cartDocs = await cartCollection.where('userID', isEqualTo: userId).get();
      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }

      // 🎯 Clear local cart state using GlobalCartProvider
      final globalCartProvider = Provider.of<GlobalCartProvider>(context, listen: false);
      globalCartProvider.clearCart();

      // 🟢 Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order submitted successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessfulScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  int calculateTotalPrice() {
    return cartItems.fold(0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) {
    final orderTotal = calculateTotalPrice();
    final deliveryFee = 150;
    final grandTotal = orderTotal + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // 🎯 Banner/illustration image
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://fintech.spondias.com/images/online-payments-1.gif',
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(item.image,
                            width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(item.name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500)),
                      subtitle: Text('Qty: ${item.quantity}',
                          style: const TextStyle(color: Colors.white70)),
                      trailing: Text('₹${item.price}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // 💳 Summary section with icons
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                children: [
                  _summaryRow(Icons.shopping_bag_outlined, 'Order', '₹$orderTotal'),
                  const Divider(),
                  _summaryRow(Icons.local_shipping_outlined, 'Delivery', '₹$deliveryFee'),
                  const Divider(),
                  _summaryRow(Icons.attach_money, 'Total', '₹$grandTotal',
                      isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => submitOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text(
                  'SUBMIT ORDER',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isTotal ? Colors.black : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Colors.black : Colors.grey[800],
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
