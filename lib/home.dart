
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clothing/AdminScreens/createData.dart';
import 'package:clothing/Screens/Reset.dart';
import 'package:clothing/Screens/login.dart';
import 'package:clothing/Screens/own_services.dart';
import 'package:flutter/material.dart';


class home extends StatefulWidget {
  home({super.key});
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {

  @override
  void initState() {
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
        backgroundColor: Colors.blue,
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
        shadowColor: Colors.grey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(

              height: MediaQuery.of(context).size.height * 0.15,
              child: const DrawerHeader(
                  decoration: BoxDecoration(
                      color: Colors.blue
                  ),
                  child: Center(child: Text("Profile Page",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),))
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Home Page'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => home() ));
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Change Password'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ResetScreen() ));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('Your Cart'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ResetScreen() ));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen() ));
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Product Add Screen'),
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => creaDataAdmin() ));
              },
            ),
          ],
        ),
      ) ,




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