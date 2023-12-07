import 'package:flutter/material.dart';
import 'package:giydir_mvp2/utils/colors.dart';
import 'package:giydir_mvp2/widgets/text_input.dart';

class BottomScreen extends StatefulWidget {
  const BottomScreen({super.key});

  @override
  State<BottomScreen> createState() => _BottomScreenState();
}

class _BottomScreenState extends State<BottomScreen> {
  final TextEditingController _bottomLinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed:  () => Navigator.of(context).pop(
                      MaterialPageRoute(
                          builder: (context) => const BottomScreen()),
                    ),
        ),
        title: const Text(
          'Bottom',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        actions: const <Widget>[
          TextButton(
            onPressed: null,
            child: Text(
              "Add new +",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFieldInput(
                    textEditingController: _bottomLinkController,
                    labelText: 'Link',
                    textInputType: TextInputType.text),
                const SizedBox(
                  height: 20,
                ),
                TextFieldInput(
                    textEditingController: _bottomLinkController,
                    labelText: 'Size',
                    textInputType: TextInputType.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
