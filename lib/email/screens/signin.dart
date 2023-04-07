import 'dart:async';

import 'package:authentication/email/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../phone/signin_with_phone.dart';
import '../../project_screens/list_screen.dart';
import '../reusable_widgets/reusable_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  bool isLoading = false;
  bool isObscure = true;

  double h = 160;
  double w = 140;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (h == 160) {
          h = 260;
          w = 240;
        } else {
          h = 160;
          w = 140;
        }
        setState(() {});
      });
    });
    super.initState();
  }
  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade400,
              Colors.purple,
              Colors.blue.shade600,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(children: [
              SizedBox(
                width: 240,
                height: 260,
                child: Center(
                  child: AnimatedContainer(
                    height: h,
                    width: w,
                    duration: const Duration(seconds: 1),
                    child: logoWidget("assets/loginlogo.png"),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              emailTextField(),
              const SizedBox(height: 20),
              passwordTextField(context),
              const SizedBox(height: 20),
              signInButton(context),
              const SizedBox(height: 20),
              signUpOption(context),
              const SizedBox(height: 25),
              signInWithNo(context),
            ]),
          ),
        ),
      ),
    );
  }

  Widget emailTextField() {
    return TextField(
      controller: _emailTextController,
      enableSuggestions: true,
      autocorrect: true,
      autofocus: false,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.person_outline,
          color: Colors.white70,
        ),
        labelText: "Enter emailAddress",
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget passwordTextField(BuildContext context) {
    return TextField(
      controller: _passwordTextController,
      obscuringCharacter: '*',
      obscureText: isObscure,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Colors.white70,
        ),
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              isObscure = !isObscure;
            });
          },
          child: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
        ),
        labelText: 'Enter Password',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: TextInputType.visiblePassword,
    );
  }

  Widget signInButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
      ),
      child: ElevatedButton(
          onPressed: () async {
            String email = _emailTextController.text.trim();
            String password = _passwordTextController.text.trim();
            if (email.isEmpty || password.isEmpty) {
              showSnackbarMsg(context, 'Please fill the details!');
            }
            setState(() {
              isLoading = true;
            });
            await loginAccount();
            setState(() {
              isLoading = false;
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: Colors.purple),
                )
              : const Text(
                  'SIGN IN',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )),
    );
  }

  Widget signUpOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have account? ",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const SignUp()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget signInWithNo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const PhoneSignIn()));
      },
      child: const Text(
        "Sign In With Phone Number",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> loginAccount() async {
    String email = _emailTextController.text.trim();
    String password = _passwordTextController.text.trim();

    _emailTextController.clear();
    _passwordTextController.clear();
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((value) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ListScreen())));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackbarMsg(context, 'No user found for that email');
      } else if (e.code == 'wrong-password') {
        showSnackbarMsg(context, 'Wrong password');
      }
    }
  }
}
