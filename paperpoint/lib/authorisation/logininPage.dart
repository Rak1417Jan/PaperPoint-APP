import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as dartdev show log;
import 'package:paperpoint/authorisation/reusable_widgets.dart';
import 'package:paperpoint/authorisation/forgotpassPage.dart';
import 'package:paperpoint/authorisation/signupPage.dart';
import 'package:paperpoint/Constants/Colors/colors.dart';
import 'package:paperpoint/orderOnline.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  bool _loading = false; // Added loading state

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenheight * 0.08, screenWidth * 0.05, 0),
            child: Column(
              children: <Widget>[
                // Image.asset(
                //   'assets/companyLogo.png',
                //   width: screenWidth * 0.715,
                // ),
                Lottie.asset('assets/logIn.json',width: screenWidth * 0.715,repeat: true),
                SizedBox(height: screenheight * 0.032),
                reusableTextField("Enter Email", Icons.email, false, _emailTextController),
                SizedBox(height: screenheight * 0.032),
                reusableTextField("Enter Password", Icons.lock, true, _passwordTextController),
                SizedBox(height: screenheight * 0.032),
                forgetPassword(context),
                firebaseUIButton(context, "Sign In", () async {
                  // Set loading state to true
                  setState(() {
                    _loading = true;
                  });

                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderOnline()),
                    );
                  } catch (error) {
                    // Log the error
                    dartdev.log("Error ${error.toString()}");
                    _showErrorSnackbar(error.toString());
                  } finally {
                    // Set loading state to false when complete (whether success or error)
                    setState(() {
                      _loading = false;
                    });
                  }
                },
                    _loading), // Pass loading state to firebaseUIButton
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: screenheight * 0.056,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPassword())),
      ),
    );
  }
  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,

      ),
    );
  }
}

Widget firebaseUIButton(BuildContext context, String buttonText, VoidCallback onPressed, bool loading) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50.0,
    margin: const EdgeInsets.symmetric(vertical: 20.0),
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading ? CircularProgressIndicator() : Text(buttonText),
    ),
  );
}
