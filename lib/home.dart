
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserScreens/AuthenticationScreen/login.dart';
import 'UserScreens/Service/own_services.dart';


class home extends StatefulWidget {
  home({super.key});
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {

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

    AnalyticsEvents.logScreenView(screenName: 'HomeScreen', ScreenIndex: '1');
    super.initState();
  }


  final List<String> images = [
    'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/936611/pexels-photo-936611.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/1410235/pexels-photo-1410235.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/936611/pexels-photo-936611.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/936611/pexels-photo-936611.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
  ];

  final TextEditingController userPrompt = TextEditingController();
  final ScrollController _scrollController = ScrollController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.shopping_cart),
          )
        ],
      ),



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
                        Text('Update User Profile', style: TextStyle(color: Colors.white)),
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



      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CarouselSlider(
            items: images.map((imageUrl){
              return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity,),
              );
            }).toList(),
            options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.3,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.easeInOut,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(seconds: 1),
                viewportFraction: 0.8
            )
        ),
      ),
    );
  }
}