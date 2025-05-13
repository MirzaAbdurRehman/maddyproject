import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clothing/AdminScreens/product_Detail.dart';
import 'package:clothing/AdminScreens/update_profile.dart';
import 'package:clothing/AdminScreens/user_OrderHistory.dart';
import 'package:clothing/Screens/Reset.dart';
import 'package:clothing/Screens/login.dart';
import 'package:clothing/Services/whatsapp_service.dart';
import 'package:clothing/cartProviderModel/GlobalCart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AddToCartScreen/AddCartData.dart';
import '../Screens/faqs.dart';
import '../Screens/own_services.dart';

class UserFetchScreen extends StatefulWidget {
  const UserFetchScreen({super.key});
  @override
  State<UserFetchScreen> createState() => _UserFetchScreenState();
}

class _UserFetchScreenState extends State<UserFetchScreen>
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



  var doc;
  var productName;
  var productPrice1 ;
  var productInfo  ;
  var productDescription ;
  var productImage ;
  var data_id;

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
          color: Colors.black, // Set the drawer background to black
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('usersinfo')
                .where("email", isEqualTo: user_id)
                .snapshots(),
            builder: (context, snapshot) {
              if (ConnectionState.waiting == snapshot.connectionState) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error', style: TextStyle(color: Colors.white)));
              }
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var Name = snapshot.data!.docs[index]['name'];
                    var Address = snapshot.data!.docs[index]['address'];
                    var Phone = snapshot.data!.docs[index]['phone'];
                    String pImage = snapshot.data!.docs[index]['image'];
                    var data_id = snapshot.data!.docs[index].id;

                    return Column(
                      children: [
                        // Container(
                        //   width: double.infinity,
                        //   height: 80,
                        //   child: const DrawerHeader(
                        //     decoration: BoxDecoration(color: Colors.black),
                        //     child: Text(
                        //       ' Profile',
                        //       style: TextStyle(color: Colors.white, fontSize: 30),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 30),
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: pImage,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                        SizedBox(height: 20),
                        ListTile(
                          leading: Icon(Icons.person, color: Colors.blue),
                          title: Text(Name, style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(height: 20),
                        ListTile(
                          leading: Icon(Icons.delivery_dining_outlined, color: Colors.red[500]),
                          title: Text(Address, style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),

                        ListTile(
                          leading: Icon(Icons.password, color: Colors.orange),
                          title: Text('Forget Password', style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  ResetScreen()));
                          },
                        ),

                        ListTile(
                          leading: Icon(Icons.shopping_bag, color: Colors.blue),
                          title: Text('Orders', style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  User_OrderHistory()));
                          },
                        ),

                        ListTile(
                          leading: Icon(Icons.receipt_long_outlined, color: Colors.red),
                          title: Text('FAQS', style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  FaqsScreen()));
                          },
                        ),

                        SizedBox(height: 20),
                        ListTile(
                          leading: Icon(Icons.phone, color: Colors.green),
                          title: Text(Phone, style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 34,
                          margin: EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Metropolis'),
                            ),
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
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton(
                              onPressed: (){
                                WhatsappService.openWhatsappForMessage('923072318609', 'Hi, is anyone available to assist me? I need help resolving a query.');
                              }, icon: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.green,
                            size: 28,
                          )
                          ),
                        ),
                        TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => update_current_User(
                                id1: data_id,
                                name1: Name,
                                address1: Address,
                                phone_number1: Phone,
                                img1: pImage,
                              )));
                            },
                            child: Text('Update User Profile', style: TextStyle(color: Colors.white))),
                      ],
                    );
                  },
                );
              }
              return Center(
                child: Text('There is no Data Found', style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(


        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
                onPressed: (){
                  WhatsappService.openWhatsappForMessage('923072318609', 'Hi, is anyone available to assist me? I need help resolving a query.');
                }, icon: FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.green,
              size: 28,
            )
            ),
          ),
    Padding(
    padding: const EdgeInsets.only(right: 22.0),
    child: InkWell(
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AddtoCart()),
    );
    },
    child: Stack(
    children: [
    Icon(
    Icons.shopping_basket_outlined,
    color: Colors.pink,
    size: 30,
    ),
    Positioned(
    left: 16,
    bottom: 15,
    child: Consumer<GlobalCartProvider>(
    builder: (context, cartProvider, child) {
    return Container(
    padding: const EdgeInsets.all(2), // Reduced padding
    decoration: BoxDecoration(
    color: Colors.red,
    shape: BoxShape.circle,
    ),
    constraints: BoxConstraints(minWidth: 16, minHeight: 18), // Smaller size
    child: Center(
    child: Text(
    '${cartProvider.totalCount}',
    style: TextStyle(color: Colors.white, fontSize: 10), // Smaller font
    ),
    ),
    );
    },
    ),
    )
    ],
    ),
    ),
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
            child: Row(
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
                  // ✅ Define all variables locally inside itemBuilder
                  final doc = products[index];
                  final String productName = doc['productName'];
                  final String productPrice1 = doc['productPrice'];
                  final String productInfo = doc['productInfo'];
                  final String productDescription = doc['productDescription'];
                  final String productImage = doc['image'];
                  final String data_id = doc.id;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriesDetailedPage(
                            pid: data_id,
                            productName1: productName,
                            productPrice1: productPrice1,
                            productImage1: productImage,
                            productInfo1: productInfo,
                            productDescription1: productDescription,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,

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
                              'Rs: $productPrice1',
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
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final globalCart = Provider.of<GlobalCartProvider>(context, listen: false);
                                  final productPrice = double.parse(productPrice1);

                                  QuerySnapshot existing = await FirebaseFirestore.instance
                                      .collection('AddtoCartData')
                                      .where('userID', isEqualTo: user_id)
                                      .where('pid', isEqualTo: data_id)
                                      .get();

                                  if (existing.docs.isNotEmpty) {
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
                                        backgroundColor: Colors.black,
                                      ),
                                    );
                                  } else {
                                    await FirebaseFirestore.instance.collection('AddtoCartData').add({
                                      'pid': data_id,
                                      'userID': user_id,
                                      'count': 1,
                                      'total_price': productPrice,
                                      'productName': productName,
                                      'productPrice': productPrice1,
                                      'productImage': productImage,
                                    });

                                    globalCart.increaseCount(productPrice);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Item successfully added to cart!'),
                                        backgroundColor: Colors.green[600],
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black
                                ),
                                child: const Text('Add To Cart',style: TextStyle(color: Colors.white),),
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
