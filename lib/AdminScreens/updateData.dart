import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class UpdateClothing extends StatefulWidget {
  final String id1;
  final String productName1;
  final String productPrice1;
  final String productInfo1;
  final String productDescription1;
  final String img1;

  UpdateClothing({
    required this.id1,
    required this.productName1,
    required this.productPrice1,
    required this.productInfo1,
    required this.productDescription1,
    required this.img1,
  });

  @override
  State<UpdateClothing> createState() => _UpdateClothingState();
}

class _UpdateClothingState extends State<UpdateClothing> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productInfoController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();

  File? pImage;
  Uint8List? webImg;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    productNameController.text = widget.productName1;
    productPriceController.text = widget.productPrice1;
    productInfoController.text = widget.productInfo1;
    productDescriptionController.text = widget.productDescription1;
  }

  @override
  void dispose() {
    productNameController.dispose();
    productPriceController.dispose();
    productInfoController.dispose();
    productDescriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          var f = await pickedFile.readAsBytes();
          setState(() {
            webImg = f;
            pImage = null;
          });
        } else {
          setState(() {
            pImage = File(pickedFile.path);
            webImg = null;
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  Future<void> updateProduct(String imageUrl) async {
    Map<String, dynamic> updatedData = {
      'productName': productNameController.text.trim(),
      'productPrice': productPriceController.text.trim(),
      'productInformation': productInfoController.text.trim(),
      'productDescription': productDescriptionController.text.trim(),
      'image': imageUrl,
    };

    await FirebaseFirestore.instance
        .collection('ClothingData')
        .doc(widget.id1)
        .update(updatedData);
  }

  Future<void> updateImageAndData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String imageUrl = widget.img1;

      if (webImg != null || pImage != null) {
        if (widget.img1.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(widget.img1).delete();
        }

        UploadTask uploadTask;
        if (kIsWeb) {
          uploadTask = FirebaseStorage.instance
              .ref()
              .child('Product_Images')
              .child(Uuid().v4())
              .putData(webImg!);
        } else {
          uploadTask = FirebaseStorage.instance
              .ref()
              .child('Product_Images')
              .child(Uuid().v4())
              .putFile(pImage!);
        }

        TaskSnapshot snap = await uploadTask;
        imageUrl = await snap.ref.getDownloadURL();
      }

      await updateProduct(imageUrl);

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Error updating data: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success 🎉'),
        content: Text('Product updated successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Clothing', style: TextStyle(fontSize: 25)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: webImg != null
                        ? MemoryImage(webImg!)
                        : pImage != null
                        ? FileImage(pImage!) as ImageProvider
                        : NetworkImage(widget.img1),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 20,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                buildTextField(controller: productNameController, label: 'Product Name'),
                SizedBox(height: 15),
                buildTextField(controller: productPriceController, label: 'Product Price', inputType: TextInputType.number),
                SizedBox(height: 15),
                buildTextField(controller: productInfoController, label: 'Product Information', inputType: TextInputType.text),
                SizedBox(height: 15),
                buildTextField(controller: productDescriptionController, label: 'Product Description', inputType: TextInputType.text),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        updateImageAndData();
                      }
                    },
                    child: Text('Update', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
