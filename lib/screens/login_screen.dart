import 'package:flutter/material.dart';
import 'package:giydir_mvp2/resources/auth_methods.dart';
import 'package:giydir_mvp2/responsive/mobile_screen_layout.dart';
import 'package:giydir_mvp2/responsive/responsive_layout.dart';
import 'package:giydir_mvp2/responsive/web_screen_layout.dart';
import 'package:giydir_mvp2/screens/signup_screen.dart';
import 'package:giydir_mvp2/utils/global_variable.dart';
import 'package:giydir_mvp2/utils/utils.dart';
import 'package:giydir_mvp2/widgets/text_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
//changes now
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Please enter both email and password.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String res =
        await AuthMethods().loginUser(email: email, password: password);

    if (res == 'success') {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
          (route) => false,
        );

        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });

      if (res.contains('supplied auth credential')) {
        // ignore: use_build_context_synchronously
        showSnackBar(context,
            'Wrong email or password. Please check your email and password.');
      }
    }
  }

  void forgotPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      showSnackBar(context, 'Please enter your email.');
      return;
    }

    try {
      await AuthMethods().resetPassword(email, context);
      // ignore: use_build_context_synchronously
      showSnackBar(context, 'Password reset email sent to $email');
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, 'Error sending password reset email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Container(),
              ),
              const Text(
                'Login',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 64,
              ),
              TextFieldInput(
                  labelText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                  icon: Icons.email),
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
                height: 70,
              ),
              InkWell(
                onTap: loginUser,
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
                          'Login',
                          style: TextStyle(fontSize: 20),
                        )
                      : const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                flex: 2,
                child: Container(
                  height: 30,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Dont have an account?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        ' Sign Up.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                  onTap: forgotPassword,
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(color: Colors.black),
                  )),
              const SizedBox(
                height: 60,
              )
            ],
          ),
        ),
      ),
    );
  }
}
