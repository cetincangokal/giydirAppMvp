import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String labelText;
  final IconData? icon;
  final TextInputType textInputType;
  final Function(String)? onChanged; // Callback for onChanged

  const TextFieldInput({
    Key? key,
    required this.textEditingController,
    this.isPass = false,
    required this.labelText,
    required this.textInputType,
    this.icon,
    this.onChanged, // Optional onChanged callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = UnderlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Colors.grey,
      ),
    );

    return TextField(
      controller: textEditingController,
      style: const TextStyle(color: Colors.black),
      onChanged: onChanged, // Pass onChanged callback to TextField
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 20, color: Colors.black),
        prefixIcon: Icon(
          icon,
          color: Colors.black,
        ),
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
