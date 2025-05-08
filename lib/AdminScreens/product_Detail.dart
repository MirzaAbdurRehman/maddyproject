import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../cartProviderModel/GlobalCart.dart';

class CategoriesDetailedPage extends StatefulWidget {
  final String pid;
  final String productName1;
  final String productImage1;
  final String productPrice1;
  final String productInfo1;
  final String productDescription1;

  CategoriesDetailedPage({
    required this.pid,
    required this.productName1,
    required this.productPrice1,
    required this.productImage1,
    required this.productInfo1,
    required this.productDescription1
  });

  @override
  State<CategoriesDetailedPage> createState() => _CategoriesDetailedPageState();
}

class _CategoriesDetailedPageState extends State<CategoriesDetailedPage> {
  final reviewController = TextEditingController();
  bool isLoading = false;
  String user_id = '';

  Future getUserEmail() async {
    SharedPreferences userCred = await SharedPreferences.getInstance();
    var Uemail = userCred.getString("email");
    return Uemail;
  }

  void ReviewsAdd() async {
    Map<String, dynamic> data = {
      'pid': widget.pid.toString(),
      'productName': widget.productName1,
      'Review': reviewController.text.toString(),
    };
    FirebaseFirestore.instance.collection('ReviwsData').add(data);
  }

  void AddtoCart() async {
    final globalCart = Provider.of<GlobalCartProvider>(context, listen: false);
    final productPrice = double.parse(widget.productPrice1);

    // Check if product already exists for this user
    QuerySnapshot existing = await FirebaseFirestore.instance
        .collection('AddtoCartData')
        .where('userID', isEqualTo: user_id)
        .where('pid', isEqualTo: widget.pid)
        .get();

    if (existing.docs.isNotEmpty) {
      // Update quantity and total price
      DocumentSnapshot doc = existing.docs.first;
      int currentCount = doc['count'];
      double currentTotal = double.parse(doc['total_price'].toString());

      await FirebaseFirestore.instance
          .collection('AddtoCartData')
          .doc(doc.id)
          .update({
        'count': currentCount + 1,
        'total_price': currentTotal + productPrice,
      });

      globalCart.increaseCount(productPrice);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item quantity updated in cart.'),
          backgroundColor: Colors.blue[600],
        ),
      );
    } else {
      // Add new item to cart
      Map<String, dynamic> data = {
        'pid': widget.pid,
        'userID': user_id,
        'count': 1,
        'total_price': productPrice,
        'productName': widget.productName1,
        'productPrice': widget.productPrice1,
        'productImage': widget.productImage1,
      };

      await FirebaseFirestore.instance.collection('AddtoCartData').add(data);
      globalCart.increaseCount(productPrice);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item successfully added to cart!'),
          backgroundColor: Colors.green[600],
        ),
      );
    }
  }



  @override
  void initState() {
    getUserEmail().then((value) {
      setState(() {
        user_id = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Product Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.productImage1,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error_outline),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Name: ${widget.productName1}',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  'Price: ${widget.productPrice1}.Rs',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
                SizedBox(height: 8),
                Text(
                  'Info: ${widget.productInfo1}',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Text(
                  'Description: ${widget.productDescription1}',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: reviewController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Write your review...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon: Icon(Icons.reviews_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        ReviewsAdd();
                        AddtoCart();
                        isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Add to Cart",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
