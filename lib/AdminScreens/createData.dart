import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'Fetch_Data_Screen.dart';

class creaDataAdmin extends StatefulWidget {
  const creaDataAdmin({super.key});

  @override
  State<creaDataAdmin> createState() => _creaDataAdminState();
}

class _creaDataAdminState extends State<creaDataAdmin> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productInfoController = TextEditingController();
  final TextEditingController productDescriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  File? pImage;
  Uint8List? webImg;
  bool isLoading = false;

  // 🔽 Dropdown related variables
  String selectedCollection = 'ClothingData';
  List<String> collectionOptions = [
    'ClothingData',
    'ElectronicsData',
    'ShoesData',
  ];

  Future<void> productImage() async {
    if (!_formKey.currentState!.validate()) return;

    if ((kIsWeb && webImg == null) || (!kIsWeb && pImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String getImageUrl = '';
      if (kIsWeb) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('Product_Clothing_Images')
            .child(Uuid().v4())
            .putData(webImg!, SettableMetadata(contentType: 'image/jpeg'));
        TaskSnapshot taskSnapshot = await uploadTask;
        getImageUrl = await taskSnapshot.ref.getDownloadURL();
      } else {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('ProductClothingImage')
            .child(Uuid().v4())
            .putFile(pImage!, SettableMetadata(contentType: 'image/jpeg'));
        TaskSnapshot taskSnapshot = await uploadTask;
        getImageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await ProductAddInfo(getImageUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image Upload Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> ProductAddInfo(String imageUrl) async {
    final String uid = Uuid().v1();

    Map<String, dynamic> data = {
      'productName': productNameController.text.trim(),
      'productPrice': productPriceController.text.trim(),
      'productInfo': productInfoController.text.trim(),
      'productDescription': productDescriptionController.text.trim(),
      'id': uid,
      'image': imageUrl,
    };

    try {
      await FirebaseFirestore.instance.collection(selectedCollection).doc(uid).set(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data submitted to $selectedCollection", style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClothingFetchScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget customTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String errorText,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
        validator: (value) => (value == null || value.isEmpty) ? errorText : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  if (kIsWeb) {
                    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickImage != null) {
                      var convertedFile = await pickImage.readAsBytes();
                      setState(() {
                        webImg = convertedFile;
                      });
                    }
                  } else {
                    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickImage != null) {
                      File convertedFile = File(pickImage.path);
                      setState(() {
                        pImage = convertedFile;
                      });
                    }
                  }
                },
                child: kIsWeb
                    ? CircleAvatar(
                  radius: 65,
                  backgroundImage: webImg != null ? MemoryImage(webImg!) : null,
                  backgroundColor: Colors.green.shade100,
                )
                    : CircleAvatar(
                  radius: 65,
                  backgroundImage: pImage != null ? FileImage(pImage!) : null,
                ),
              ),
              SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Enter Product Details",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // 🔽 Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Collection',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                  ),
                  value: selectedCollection,
                  items: collectionOptions.map((String collection) {
                    return DropdownMenuItem<String>(
                      value: collection,
                      child: Text(collection),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCollection = newValue!;
                    });
                  },
                ),
              ),
              customTextField(
                label: 'Product Name',
                icon: Icons.label,
                controller: productNameController,
                errorText: 'Please enter Product Name',
              ),
              customTextField(
                label: 'Product Price',
                icon: Icons.attach_money,
                controller: productPriceController,
                errorText: 'Please enter Product Price',
                inputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              customTextField(
                label: 'Product Info',
                icon: Icons.info_outline,
                controller: productInfoController,
                errorText: 'Please enter Product Info',
              ),
              customTextField(
                label: 'Product Description',
                icon: Icons.description,
                controller: productDescriptionController,
                errorText: 'Please enter Product Description',
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await productImage(); // Handles upload + Firestore
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Submit Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
