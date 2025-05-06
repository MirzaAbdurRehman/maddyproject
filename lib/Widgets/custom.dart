import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller1;
  final bool isShow;
  final String label;
  final String hintText;
  final IconData icon;

  const CustomTextField({
    super.key,
    required this.controller1,
    required this.icon,
    required this.label,
    required this.hintText,
    this.isShow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextFormField(
        controller: controller1,
        obscureText: isShow,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(
            icon,
            color: Colors.blue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.teal,
              width: 2.0,
            ),
          ),
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }
}