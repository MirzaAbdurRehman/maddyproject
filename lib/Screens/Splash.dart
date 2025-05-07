import 'dart:async';

import 'package:clothing/AdminScreens/Fetch_Data_Screen.dart';
import 'package:clothing/AdminScreens/UserFecthScreen.dart';
import 'package:clothing/Screens/login.dart';
import 'package:clothing/home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future getUser() async {
        //   Using Shared Prefrenes
        SharedPreferences userCredential = await SharedPreferences.getInstance();
        var userEmail = userCredential.getString('email');
        debugPrint('user Email: $userEmail');
        return userEmail;
  }

  @override
  void initState() {

    getUser().then((value) => {
      if(value != null){
         // Mean  3_Second
         Timer(const Duration(milliseconds: 2000), (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserFetchScreen() ));
         })
      }else{
         // Mean  3_Second
         Timer(const Duration(milliseconds: 2000), (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen() ));
         })
      }
    });
    super.initState();

  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.4,
              ),
              Center(
                child: Container(
                  // color: Colors.purple,
                     height: MediaQuery.of(context).size.height * 0.99,
                      width: MediaQuery.of(context).size.width * 0.99,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Lottie.asset(
                            'assets/animations/shopping.json',
                            repeat: true,
                            reverse: true
                          ),
                          Text('E-Commerce',style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),)
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}