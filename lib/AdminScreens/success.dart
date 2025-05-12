import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'UserFecthScreen.dart';

class SuccessfulScreen extends StatefulWidget {
  @override
  State<SuccessfulScreen> createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {
  // Function to switch to home page (UserFetchScreen)
  void SwitchToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserFetchScreen()),
    );
  }

  @override
  void initState() {
    // Wait for 3 seconds before navigating
    Future.delayed(const Duration(seconds: 3), SwitchToHomePage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          "Successfull Screen",
          style: TextStyle(color: Colors.white, fontSize: 29),
        ),
        centerTitle: true,
        foregroundColor: Colors.transparent,
        // elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Center(
              child: RepaintBoundary(
                child: SizedBox(
                  height: 399,
                  width: double.infinity,
                  child: Lottie.asset(
                    'assets/animations/cart.json',
                    repeat: true,
                    reverse: true,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Your order will be delivered soon',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ),
            SizedBox(height: 7),
            Center(
              child: Text(
                'Thank you for choosing our app!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
