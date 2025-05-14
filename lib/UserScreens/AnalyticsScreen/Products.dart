
import 'package:flutter/material.dart';

import '../Service/own_services.dart';
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
 
  @override
  void initState() {
    AnalyticsEvents.logScreenView(screenName: 'Product Screen', ScreenIndex: '2');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is Product Screen'),   
          ],
        ),
      ),
    );
  }
}