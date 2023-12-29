// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:giydir_mvp2/providers/user_providers.dart';
import 'package:giydir_mvp2/resources/firestore_methods.dart';
import 'package:giydir_mvp2/utils/colors.dart';
import 'package:giydir_mvp2/utils/utils.dart';
import 'package:giydir_mvp2/widgets/text_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  String? _link;
  String? _selectedCategory;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _topLinkController = TextEditingController();

  Map<String, List<String>> additionalClothesInfo = {};

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });

    try {
      String res = await FireStoreMethods().uploadPost(
          _descriptionController.text, _file!, uid, username, profImage,
          links: additionalClothesInfo);

      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(
            context,
            'Posted!',
          );
        }
        clearImage();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void _updateLink(String link) {
    setState(() {
      _link = link;
    });
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void _addClothesInfo() {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 243, 242, 242),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: SizedBox(
            height: 600,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Clothes Link',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFieldInput(
                    textEditingController: _topLinkController,
                    labelText: 'Link',
                    textInputType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        _updateLink(value);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Yarı yarıya küçültmek için Expanded kullanılıyor
                      SizedBox(
                        width: 150,
                        child: DropdownButton<String>(
                          dropdownColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          iconDisabledColor:
                              const Color.fromARGB(255, 159, 157, 157),
                          value: _selectedCategory,
                          hint: const Text(
                            'Category',
                            style: TextStyle(color: Colors.black),
                          ),
                          items: [
                            "Top",
                            "Bottom",
                            "Charms",
                            "Shoes",
                            "Winter Wear",
                          ].map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        // Use _link when pressing the ElevatedButton
                        // ignore: avoid_print
                        print("Link: $_link, $_selectedCategory");

                        // Eğer kategori daha önce eklenmemişse, listeye ekle
                        if (!additionalClothesInfo
                            .containsKey(_selectedCategory)) {
                          additionalClothesInfo[_selectedCategory!] = [];
                        }

                        // Link'i ilgili kategoriye ekle
                        additionalClothesInfo[_selectedCategory!]!
                            .add(_topLinkController.text);

                        // Modalı kapat
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: const Text(
                        "Add Clothes",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _file == null
        ? Center(
            child: IconButton(
              icon: const Icon(
                Icons.upload,
                color: Colors.black,
                size: 50,
              ),
              onPressed: () => _selectImage(context),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: clearImage,
              ),
              title: const Text(
                'Post to',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImage(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 94.0,
                        width: 71.0,
                        child: AspectRatio(
                          aspectRatio: 90 / 80,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter,
                                image: MemoryImage(_file!),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextField(
                            controller: _descriptionController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                                hintText: "Write a caption...",
                                hintStyle: TextStyle(color: Colors.black),
                                border: InputBorder.none),
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      _addClothesInfo();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Clothes',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Security Settings',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                // Yeni eklenen kategori ve link bilgilerini gösteren alanlar
                for (var entry in additionalClothesInfo.entries)
                  for (var link in entry.value)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Category: ${entry.key}, Link: $link',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                additionalClothesInfo[entry.key]!.remove(link);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          );
  }
}
