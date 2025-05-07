import 'dart:io';
import 'package:clothing/AdminScreens/Fetch_Data_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class update_current_User extends StatefulWidget {
  String id1;
  String name1;
  String address1;
  String phone_number1;
  String img1;

  update_current_User({
    required this.id1,
    required this.name1,
    required this.address1,
    required this.phone_number1,
    required this.img1,
  });

  @override
  State<update_current_User> createState() => _update_current_UserState();
}

final _formkey = GlobalKey<FormState>();

class _update_current_UserState extends State<update_current_User> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  File? pImage;
  Uint8List? webImg;
  bool isLoading = false;

  @override
  void initState() {
    nameController.text = widget.name1;
    addressController.text = widget.address1;
    phoneController.text = widget.phone_number1;
    super.initState();
  }

  void updateData(String imageUrl) async {
    Map<String, dynamic> updatedData = {
      'name': nameController.text.trim(),
      'address': addressController.text.trim(),
      'phone': phoneController.text.trim(),
      'image': imageUrl,
    };

    await FirebaseFirestore.instance
        .collection('usersinfo')
        .doc(widget.id1)
        .update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Update Data Successfully")),
    );

    Navigator.pop(context);
  }

  void productImage() async {
    setState(() {
      isLoading = true;
    });

    String getImageUrl = widget.img1; // default to previous image

    try {
      if (webImg != null || pImage != null) {
        // If a new image is selected
        // Delete old image
        await FirebaseStorage.instance.refFromURL(widget.img1).delete();

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
              .child('ProductImage')
              .child(Uuid().v4())
              .putFile(pImage!);
        }

        TaskSnapshot snapshot = await uploadTask;
        getImageUrl = await snapshot.ref.getDownloadURL();
      }

      updateData(getImageUrl);
    } catch (e) {
      print("Image update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating data")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          iconSize: 24,
          padding: EdgeInsets.only(left: 15.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Update Profile",
              style: TextStyle(fontSize: 32, fontFamily: 'Libre'),
            ),
            SizedBox(height: 5),
            Text(
              "Please fill the details and Update Data",
              style: TextStyle(color: Colors.grey, fontFamily: "Metropolis"),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if (kIsWeb) {
                  XFile? pickImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickImage != null) {
                    var convertedFile = await pickImage.readAsBytes();
                    setState(() {
                      webImg = convertedFile;
                    });
                  }
                } else {
                  XFile? pickImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickImage != null) {
                    File convertedFile = File(pickImage.path);
                    setState(() {
                      pImage = convertedFile;
                    });
                  }
                }
              },
              child: CircleAvatar(
                radius: 65,
                backgroundImage: kIsWeb
                    ? (webImg != null
                    ? MemoryImage(webImg!)
                    : NetworkImage(widget.img1) as ImageProvider)
                    : (pImage != null
                    ? FileImage(pImage!)
                    : NetworkImage(widget.img1) as ImageProvider),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: 30),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  buildTextField("Name", nameController, TextInputType.text),
                  buildTextField(
                      "Address", addressController, TextInputType.text),
                  buildTextField(
                      "Phone Number", phoneController, TextInputType.number),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  child: isLoading
                      ? CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                      : Text(
                    "Update Data",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontFamily: 'Metropolis'),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                    if (_formkey.currentState!.validate()) {
                      productImage();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildTextField(
      String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, right: 28, top: 15),
      child: Container(
        height: 60,
        child: TextFormField(
          keyboardType: type,
          controller: controller,
          decoration: InputDecoration(
            label: Text(label, style: TextStyle(color: Colors.black)),
            fillColor: Colors.grey[200],
            filled: true,
            hintText: "Enter $label",
            hintStyle: TextStyle(
              color: Colors.black,
              fontFamily: "Metropolis",
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
              BorderSide(color: const Color.fromARGB(255, 66, 164, 244)),
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
              BorderSide(color: const Color.fromARGB(253, 238, 238, 238)),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "$label is Required";
            }
            return null;
          },
        ),
      ),
    );
  }
}
