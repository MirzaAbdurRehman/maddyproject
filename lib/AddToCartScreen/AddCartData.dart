
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cartProviderModel/GlobalCart.dart';
import '../cartProviderModel/cartQuantity.dart';

class AddtoCart extends StatefulWidget {
  @override
  State<AddtoCart> createState() => _AddtoCartState();
}

class _AddtoCartState extends State<AddtoCart> {
  String user_id = '';
  bool isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Cart",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user_id.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('AddtoCartData')
              .where('userID', isEqualTo: user_id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading cart.'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Your cart is empty.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data_id = doc.id;
                var productName = doc['productName'];
                var productPrice = int.parse(doc['productPrice']);
                var productImage = doc['productImage'];
                var count = doc['count'];

                return ChangeNotifierProvider(
                  key: ValueKey(data_id),
                  create: (_) => CartItemProvider(
                      count: count, productPrice: productPrice),
                  child: CartItemCard(
                    dataId: data_id,
                    productName: productName,
                    productPrice: productPrice, // Pass this
                    productImage: productImage,
                    userId: user_id,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final String dataId;
  final String productName;
  final String productImage;
  final int productPrice;
  final String userId;

  const CartItemCard({
    required this.dataId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final cartItem = Provider.of<CartItemProvider>(context);
    final globalCart = Provider.of<GlobalCartProvider>(context, listen: false);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                productImage,
                height: 100,
                width: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    'Price: ₹${cartItem.totalPrice}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (cartItem.count > 1) {
                            cartItem.decrease();
                            globalCart.decreaseCount(productPrice.toDouble());

                            await FirebaseFirestore.instance
                                .collection('AddtoCartData')
                                .doc(dataId)
                                .update({
                              'count': cartItem.count,
                              'total_price': cartItem.totalPrice,
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '${cartItem.count}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () async {
                          cartItem.increase();
                          globalCart.increaseCount(productPrice.toDouble());

                          await FirebaseFirestore.instance
                              .collection('AddtoCartData')
                              .doc(dataId)
                              .update({
                            'count': cartItem.count,
                            'total_price': cartItem.totalPrice,
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Checkout logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Checkout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () async {
                          globalCart.decreaseCount(
                              cartItem.totalPrice.toDouble());
                          await FirebaseFirestore.instance
                              .collection('AddtoCartData')
                              .doc(dataId)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Item removed from cart.")),
                          );
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

