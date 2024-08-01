import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as dartdev show log;
import 'package:paperpoint/authorisation/reusable_widgets.dart';
import 'package:paperpoint/Constants/Colors/colors.dart';
import 'package:paperpoint/authorisation/logininPage.dart';
import 'package:paperpoint/orderOnline.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _companyNameTextController = TextEditingController();
  final TextEditingController _phoneNumberTextController = TextEditingController();
  bool _loading = false; // Added loading state

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: backgroundColor),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenheight * 0.08, screenWidth * 0.05, 0),
            child: Column(
              children: <Widget>[
                // Image.asset(
                //   'assets/companyLogo.png',
                //    // Adjust the width as needed
                // ),
                Lottie.asset('assets/signIn.json',width: screenWidth * 0.715,repeat: true),
                SizedBox(height: screenheight * 0.032),
                Text(
                  "Create an account",
                  style: TextStyle(fontSize: screenWidth * 0.09, color: Colors.black, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: screenheight * 0.032,
                ),
                reusableTextField(
                  "Enter Company Name",
                  Icons.home_repair_service,
                  false,
                  _companyNameTextController,
                ),
                SizedBox(
                  height: screenheight * 0.016,
                ),
                reusableTextField(
                  "Enter Phone Number",
                  Icons.phone,
                  false,
                  _phoneNumberTextController,
                ),
                SizedBox(
                  height: screenheight * 0.016,
                ),
                reusableTextField(
                  "Enter Email Id",
                  Icons.email,
                  false,
                  _emailTextController,
                ),
                SizedBox(
                  height: screenheight * 0.016,
                ),
                reusableTextField(
                  "Enter Password",
                  Icons.lock,
                  true,
                  _passwordTextController,
                ),
                SizedBox(
                  height: screenheight * 0.016,
                ),
                signUpOption(),
                SizedBox(
                  height: screenheight * 0.008,
                ),
                firebaseUIButton(context, "Sign Up", () async {
                  // Set loading state to true
                  setState(() {
                    _loading = true;
                  });

                  try {
                    // Create user with email and password
                    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    );

                    // Get the user UID
                    String userUid = userCredential.user!.uid;

                    // Store user details in Firestore
                    await FirebaseFirestore.instance.collection('users').doc(userUid).set({
                      'email': _emailTextController.text,
                      'phoneNumber': _phoneNumberTextController.text,
                      'companyName': _companyNameTextController.text,
                      'userUid': userUid, // Add user UID to the document
                    });

                    // print('User created successfully with UID: $userUid');
                  } catch (error) {
                    // Log the error
                    dartdev.log("Error $error");
                    _showErrorSnackbar(error.toString());
                    // Handle the error, e.g., show a snackbar or display an error message
                  } finally {
                    // Set loading state to false when complete (whether success or error)
                    setState(() {
                      _loading = false;
                    });
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderOnline()),
                  );
                },
                    _loading), // Pass loading state to firebaseUIButton
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
          "Already have an account?",
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
          },
          child: const Text(
            " Log in",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
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
