// SignupScreen.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:clothing/Screens/login.dart';
import 'package:clothing/Widgets/custom.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;
  Uint8List? webImg;
  File? pImage;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    if (kIsWeb) {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImg = f;
        });
      }
    } else {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          pImage = File(image.path);
        });
      }
    }
  }

  Future<String> uploadImage() async {
    UploadTask uploadTask;
    String imgId = const Uuid().v4();

    if (kIsWeb) {
      uploadTask = FirebaseStorage.instance
          .ref('Product_Images/$imgId')
          .putData(webImg!);
    } else {
      uploadTask = FirebaseStorage.instance
          .ref('Product_Images/$imgId')
          .putFile(pImage!);
    }

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> signupUser() async {
    if (_formKey.currentState!.validate()) {
      if ((kIsWeb && webImg == null) || (!kIsWeb && pImage == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String imageUrl = await uploadImage();

        await FirebaseFirestore.instance
            .collection('usersinfo')
            .doc(userCredential.user?.uid)
            .set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'address': addressController.text.trim(),
          'phone': phoneController.text.trim(),
          'id': userCredential.user?.uid,
          'image': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Error: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.black,
        title: const Text(
          "Create Account",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: kIsWeb
                          ? (webImg != null
                          ? MemoryImage(webImg!)
                          : null)
                          : (pImage != null
                          ? FileImage(pImage!)
                          : null) as ImageProvider?,
                      child: (webImg == null && pImage == null)
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller1: nameController,
                    label: "Name",
                    hintText: "Enter your full name",
                    icon: Icons.person,
                  ),
                  CustomTextField(
                    controller1: emailController,
                    label: "Email",
                    hintText: "Enter your email",
                    icon: Icons.email,
                  ),
                  CustomTextField(
                    controller1: passwordController,
                    label: "Password",
                    hintText: "Enter your password",
                    icon: Icons.lock,
                    isShow: true,
                  ),
                  CustomTextField(
                    controller1: addressController,
                    label: "Address",
                    hintText: "Enter your address",
                    icon: Icons.home,
                  ),
                  CustomTextField(
                    controller1: phoneController,
                    label: "Phone",
                    hintText: "Enter your phone number",
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signupUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Signup",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
