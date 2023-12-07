import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:giydir_mvp2/resources/auth_methods.dart';
import 'package:giydir_mvp2/responsive/mobile_screen_layout.dart';
import 'package:giydir_mvp2/responsive/responsive_layout.dart';
import 'package:giydir_mvp2/responsive/web_screen_layout.dart';
import 'package:giydir_mvp2/screens/login_screen.dart';
import 'package:giydir_mvp2/utils/colors.dart';
import 'package:giydir_mvp2/utils/utils.dart';
import 'package:giydir_mvp2/widgets/text_input.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _nameAndSurnameController =
      TextEditingController();
  bool firstValue = false;
  bool _isLoading = false;
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nickNameController.dispose();
  }

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    // signup user using our authmethodds
    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _nickNameController.text,
        nameAndSurname: _nameAndSurnameController.text,
        file: _image!);
    // if string returned is sucess, user has been created
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      if (context.mounted) {
        showSnackBar(context, res);
      }
    }
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          Stack(
            children: [
              Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(),
                        ),
                        const SizedBox(
                          height: 64,
                        ),
                        Stack(
                          children: [
                            _image != null
                                ? CircleAvatar(
                                    radius: 64,
                                    backgroundImage: MemoryImage(_image!),
                                    backgroundColor: Colors.red,
                                  )
                                : const CircleAvatar(
                                    radius: 64,
                                    backgroundImage:
                                        AssetImage("images/l60Hf.png"),
                                    backgroundColor: Colors.red,
                                  ),
                            Positioned(
                              bottom: -10,
                              left: 80,
                              child: IconButton(
                                onPressed: selectImage,
                                icon: const Icon(Icons.add_a_photo),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFieldInput(
                          labelText: 'Name and Surname',
                          textInputType: TextInputType.text,
                          textEditingController: _nameAndSurnameController,
                          icon: Icons.person,
                          isPass: false,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFieldInput(
                          labelText: 'Username',
                          textInputType: TextInputType.text,
                          textEditingController: _nickNameController,
                          icon: Icons.person,
                          isPass: false,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFieldInput(
                          labelText: 'Email',
                          textInputType: TextInputType.emailAddress,
                          textEditingController: _emailController,
                          icon: Icons.email,
                          isPass: false,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFieldInput(
                          labelText: 'Enter your password',
                          textInputType: TextInputType.text,
                          textEditingController: _passwordController,
                          icon: Icons.lock,
                          isPass: true,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFieldInput(
                          labelText: 'Enter your password again',
                          textInputType: TextInputType.text,
                          textEditingController: _passwordAgainController,
                          icon: Icons.lock,
                          isPass: true,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: signUpUser,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              color: blueColor,
                            ),
                            child: !_isLoading
                                ? const Text(
                                    'Sign up',
                                  )
                                : const CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Text(
                                'Already have an account?',
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Text(
                                  ' Login.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
