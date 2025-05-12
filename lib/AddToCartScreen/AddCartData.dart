import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AdminScreens/payment.dart';
import '../cartProviderModel/GlobalCart.dart';
import '../cartProviderModel/cartQuantity.dart';

class AddtoCart extends StatefulWidget {
  @override
  State<AddtoCart> createState() => _AddtoCartState();
}

class _AddtoCartState extends State<AddtoCart> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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

            final cartDocs = snapshot.data!.docs;
            int totalAmount = 0;
            List<CartItem> cartItems = [];

            for (var doc in cartDocs) {
              int itemTotal = parsePrice(doc['total_price']);
              totalAmount += itemTotal;

              cartItems.add(CartItem(
                pid: doc.id,
                name: doc['productName'] ?? '',
                image: doc['productImage'] ?? '',
                price: itemTotal,
                quantity: doc['count'] ?? 1,
              ));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartDocs.length,
                    itemBuilder: (context, index) {
                      var doc = cartDocs[index];
                      var dataId = doc.id;
                      var productName = doc['productName'] ?? '';
                      var productImage = doc['productImage'] ?? '';
                      int productPrice = parsePrice(doc['productPrice']);

                      int count = doc['count'] ?? 1;

                      return ChangeNotifierProvider(
                        key: ValueKey(dataId),
                        create: (_) => CartItemProvider(
                          count: count,
                          productPrice: productPrice,
                        ),
                        child: CartItemCard(
                          dataId: dataId,
                          productName: productName,
                          productImage: productImage,
                          productPrice: productPrice,
                          userId: user_id,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$totalAmount Rs.",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckOut(
                          userId: user_id,
                          cartItems: cartItems,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Proceed to Checkout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  int parsePrice(dynamic price) {
    if (price is num) return price.toInt();
    if (price is String) return int.tryParse(price) ?? 0;
    return 0;
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
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              productImage,
              height: 90,
              width: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                globalCart.decreaseCount(cartItem.totalPrice.toDouble());

                await FirebaseFirestore.instance
                    .collection('AddtoCartData')
                    .doc(dataId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Item removed from cart.")),
                );
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
