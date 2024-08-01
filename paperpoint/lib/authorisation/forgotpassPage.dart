import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paperpoint/authorisation/reusable_widgets.dart';
import 'package:paperpoint/Constants/Colors/colors.dart';
import 'package:paperpoint/authorisation/signupPage.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailTextController = TextEditingController();
  bool _loading = false; // Added loading state

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                //   width: screenWidth * 0.715, // Adjust the width as needed
                // ),
                Lottie.asset('assets/forgotPassword.json',width: screenWidth,repeat: true),
                SizedBox(
                  height: screenheight * 0.032,
                ),
                reusableTextField(
                    "Enter Email Id", Icons.person_outline, false, _emailTextController),
                SizedBox(
                  height: screenheight * 0.032,
                ),
                firebaseUIButton(context, "Reset Password", () {
                  resetPassword();
                }, _loading),
                goBack(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget goBack(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: screenheight * 0.056,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Try Signing Up Now?",
          textAlign: TextAlign.right,
        ),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
      ),
    );
  }

  void resetPassword() {
    // Set loading state to true
    setState(() {
      _loading = true;
    });

    FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailTextController.text)
        .then((value) {
      // Set loading state to false when complete
      setState(() {
        _loading = false;
      });

      Navigator.of(context).pop();
    }).catchError((error) {
      // Set loading state to false in case of error
      setState(() {
        _loading = false;
      });
      _showErrorSnackbar(error.toString());
      // Handle the error, e.g., show a snackbar or display an error message
    });
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
