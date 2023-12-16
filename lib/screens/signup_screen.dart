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
        file: _image!,
        context: context);
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
        body: SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 45,
              ),
              _image != null
                  ? GestureDetector(
                      onTap: selectImage,
                      child: CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_image!),
                      ),
                    )
                  : GestureDetector(
                    onTap: selectImage,
                    child: const CircleAvatar(
                        radius: 64,
                        backgroundImage: AssetImage("images/l60Hf.png"),
                      ),
                  ),
              const SizedBox(
                height: 30,
              ),
              TextFieldInput(
                labelText: 'Name and Surname',
                textInputType: TextInputType.text,
                textEditingController: _nameAndSurnameController,
                icon: Icons.person,
                isPass: false,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldInput(
                labelText: 'Username',
                textInputType: TextInputType.text,
                textEditingController: _nickNameController,
                icon: Icons.person,
                isPass: false,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldInput(
                labelText: 'Email',
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
                icon: Icons.email,
                isPass: false,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldInput(
                labelText: 'Enter your password',
                textInputType: TextInputType.text,
                textEditingController: _passwordController,
                icon: Icons.lock,
                isPass: true,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldInput(
                labelText: 'Enter your password again',
                textInputType: TextInputType.text,
                textEditingController: _passwordAgainController,
                icon: Icons.lock,
                isPass: true,
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.grey,
                      side: const BorderSide(width: 2, color: Colors.grey),
                      value: firstValue,
                      onChanged: (value) {
                        setState(() {
                          firstValue = value!;
                        });
                      }),
                  Expanded(
                    child: RichText(
                        text: const TextSpan(children: [
                      TextSpan(
                        text: "Bu ifadeyi onaylayarak ",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      TextSpan(
                        text: 'Kullanım Şartları, Gizlilik Bildirimi',
                        style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                      TextSpan(
                        text: ' ve',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      TextSpan(
                        text: ' KVKK Aydınlatma Metnini',
                        style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                      TextSpan(
                        text: ' kabul ettiğimi bildiririm.',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      )
                    ])),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: signUpUser,
                child: Container(
                  width: 257,
                  height: 56,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    color: Colors.grey,
                  ),
                  child: !_isLoading
                      ? const Text(
                          'Sign up',
                          style: TextStyle(fontSize: 20),
                        )
                      : const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        ' Login.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      onTap: () {
                        print('need help');
                      },
                      child: const Text(
                        'Need help?',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
