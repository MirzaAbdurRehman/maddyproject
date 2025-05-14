
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clothing/AdminScreens/createData.dart';
import 'package:clothing/UserScreens/product_Detail.dart';
import 'package:clothing/AdminScreens/updateData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UserScreens/AuthenticationScreen/login.dart';
import '../UserScreens/Service/own_services.dart';
import 'Admin_OrderHistory.dart';
import 'ReviewsScreen.dart';

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


  String user_id = '';


  Future getUser() async {
    //   Using Shared Prefrenes
    SharedPreferences userCredential = await SharedPreferences.getInstance();
    var Uemail = userCredential.getString('email');
    debugPrint('user Email: $Uemail');
    return Uemail;
  }

  @override
  void initState() {

    getUser().then((value) {
      setState(() {
        user_id = value;
      });
      // print('${user_id}');
    });

    _tabController = TabController(length: 3, vsync: this);

    AnalyticsEvents.logScreenView(screenName: 'HomeScreen', ScreenIndex: '1');
    super.initState();
  }

  final List<String> filterOptions = [
    'None',
    'Price: Low to High',
    'Price: High to Low',
  ];

  final List<String> images = [
    'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/936611/pexels-photo-936611.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/1410235/pexels-photo-1410235.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/936611/pexels-photo-936611.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/936611/pexels-photo-936611.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
  ];



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(

      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              SizedBox(height: 60),
              Text(
                'Admin',
                style: TextStyle(color: Colors.white,fontSize: 39),
              ),
              SizedBox(height: 30),


              ListTile(
                leading: Icon(Icons.receipt_long_outlined, color: Colors.green),
                title: Text(
                  'Product Reviews',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReviewScreen()),
                  );
                },
              ),


              ListTile(
                leading: Icon(Icons.shopping_bag, color: Colors.blue),
                title: Text(
                  'Orders Summary',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Admin_OrderHistory()),
                  );
                },
              ),


              Container(
                height: 32,
                margin: EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Metropolis',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      backgroundColor: Colors.grey[200],
      appBar: AppBar(

        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('All Products', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
                onPressed: (){
                 Navigator.push(context, MaterialPageRoute(builder: (context) => creaDataAdmin()));
                },
              child: Text('Add Data'),
            )
            ),
        ],

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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScrollableTabContent('ClothingData', screenWidth),
          _buildScrollableTabContent('ElectronicsData', screenWidth),
          _buildScrollableTabContent('ShoesData', screenWidth),
        ],
      ),
    );
  }

  Widget _buildScrollableTabContent(String collectionName, double screenWidth) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                FocusScope.of(context).unfocus();
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

          // 🔽 Compact Sorting Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 4),
            child:

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: DropdownButtonFormField<String>(
                    value: selectedFilter,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Reduced vertical padding
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Sort by",
                      labelStyle: const TextStyle(fontSize: 12), // Smaller label
                      prefixIcon: const Icon(Icons.sort, size: 16, color: Colors.grey), // Smaller icon
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25), // Smaller radius
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
                    style: const TextStyle(fontSize: 12, color: Colors.black), // Smaller text
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20), // Smaller dropdown icon
                    items: filterOptions.map((filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter, style: const TextStyle(fontSize: 12)), // Smaller dropdown text
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

          const SizedBox(height: 10),
          // 🖼️ Carousel Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: CarouselSlider(
              items: images.map((imageUrl) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.2,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.easeInOut,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(seconds: 1),
                viewportFraction: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 📦 Product List
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

              if (searchQuery.isNotEmpty) {
                products = products.where((doc) {
                  final productName = doc['productName'].toString().toLowerCase();
                  return productName.contains(searchQuery);
                }).toList();
              }

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
                  childAspectRatio: screenWidth / (MediaQuery.of(context).size.height * 0.75),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriesDetailedPage(
                            pid: data_id,
                            productName1: productName,
                            productPrice1: productPrice,
                            productImage1: productImage,
                            productInfo1: productInfo,
                            productDescription1: productDescription,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
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
                              style: TextStyle(fontSize: screenWidth > 600 ? 14 : 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Description: $productDescription',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: screenWidth > 600 ? 14 : 12),
                            ),
                            RatingBar.builder(
                              initialRating: 3,
                              itemSize: 20,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
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
                            ),
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
