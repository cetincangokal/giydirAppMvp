import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String labelText;
  final IconData? icon;
  final TextInputType textInputType;
  const TextFieldInput({
    Key? key,
    required this.textEditingController,
    this.isPass = false,
    required this.labelText,
    required this.textInputType,
     this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = UnderlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Colors.grey,
        ));

    return TextField(
      controller: textEditingController,
      style: const TextStyle(color: Colors.black),
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
        filled: true,
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
