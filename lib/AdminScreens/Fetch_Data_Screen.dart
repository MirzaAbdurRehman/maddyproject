import 'package:clothing/AdminScreens/product_Detail.dart';
import 'package:clothing/AdminScreens/updateData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ClothingFetchScreen extends StatefulWidget {
  const ClothingFetchScreen({super.key});
  @override
  State<ClothingFetchScreen> createState() => _ClothingFetchScreenState();
}

class _ClothingFetchScreenState extends State<ClothingFetchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String selectedFilter = 'None';
  String searchQuery = '';

  final List<String> filterOptions = [
    'None',
    'Price: Low to High',
    'Price: High to Low',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Products', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.orange,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Clothing Products'),
            Tab(text: 'Electronics Products'),
            Tab(text: 'Shoes Products'),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // 🔍 Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              onTapOutside: (event) {
                FocusScope.of(context).unfocus(); // Keyboard close
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Search by product name',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),


          const SizedBox(height: 6),


          // 🔽 Sorting Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: DropdownButtonFormField<String>(
                    value: selectedFilter,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Sort by",
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.sort, size: 18, color: Colors.grey),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    items: filterOptions.map((filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 📦 Product List (Grid)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList('ClothingData', screenWidth),
                _buildProductList('ElectronicsData', screenWidth),
                _buildProductList('ShoesData', screenWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(String collectionName, double screenWidth) {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong.'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('No data found in this category.'),
                );
              }

              List<DocumentSnapshot> products = snapshot.data!.docs;

              // 🔍 Filter by search
              if (searchQuery.isNotEmpty) {
                products = products.where((doc) {
                  final productName = doc['productName'].toString().toLowerCase();
                  return productName.contains(searchQuery);
                }).toList();
              }

              // 🔃 Sort by price
              if (selectedFilter == 'Price: Low to High') {
                products.sort((a, b) => int.parse(a['productPrice'].toString())
                    .compareTo(int.parse(b['productPrice'].toString())));
              } else if (selectedFilter == 'Price: High to Low') {
                products.sort((a, b) => int.parse(b['productPrice'].toString())
                    .compareTo(int.parse(a['productPrice'].toString())));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height * 0.75), // 👈 Responsive aspect ratio
                ),
                itemBuilder: (context, index) {
                  var doc = products[index];
                  var productName = doc['productName'];
                  var productPrice = doc['productPrice'];
                  var productInfo = doc['productInfo'];
                  var productDescription = doc['productDescription'];
                  var productImage = doc['image'];
                  var data_id = doc.id;

                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      CategoriesDetailedPage(
                        pid: data_id,
                        productName1: productName,
                        productPrice1: productPrice,
                        productImage1: productImage,
                        productInfo1: productInfo,
                        productDescription1: productDescription,
                      ),
                      ));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                productImage,
                                height: screenWidth > 600 ? 160 : 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              productName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth > 600 ? 18 : 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs: $productPrice',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Info: $productInfo',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth > 600 ? 14 : 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Description: $productDescription',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth > 600 ? 14 : 12,
                              ),
                            ),
                            RatingBar.builder(
                              initialRating: 3,
                              itemSize: 20,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(

                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print('Rating: $rating');
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateClothing(
                                            productName1: productName,
                                            productPrice1: productPrice,
                                            productInfo1: productInfo,
                                            productDescription1: productDescription,
                                            img1: productImage,
                                            id1: data_id,
                                            collectionName: collectionName,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection(collectionName)
                                          .doc(data_id)
                                          .delete();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Deleted Successfully")),
                                      );
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
