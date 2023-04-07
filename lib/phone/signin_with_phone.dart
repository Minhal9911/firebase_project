import 'dart:async';

import 'package:authentication/phone/verify_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../email/reusable_widgets/reusable_widget.dart';

class PhoneSignIn extends StatefulWidget {
  const PhoneSignIn({Key? key}) : super(key: key);

  @override
  State<PhoneSignIn> createState() => _PhoneSignInState();
}

class _PhoneSignInState extends State<PhoneSignIn> {
  final TextEditingController _phoneNoController = TextEditingController();

  bool isLoading = false;
  bool validate = false;

  double h = 212;
  double w = 200;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (h == 212) {
          h = 312;
          w = 300;
        } else {
          h = 212;
          w = 200;
        }
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Column(children: [
              SizedBox(
                height: 412,
                width: 412,
                child: Center(
                  child: AnimatedContainer(
                      height: h,
                      width: w,
                      duration: const Duration(seconds: 1),
                      child: logoWidget("assets/loginlogo.png")),
                ),
              ),
              const SizedBox(height: 30),
              phoneNoTextField(),
              const SizedBox(height: 30),
              signInButton(context),
            ]),
          ),
        ),
      ),
    );
  }

  Widget phoneNoTextField() {
    return TextField(
      controller: _phoneNoController,
      enableSuggestions: true,
      autocorrect: true,
      autofocus: false,
      cursorColor: Colors.white,
      maxLength: 10,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.person_outline,
          color: Colors.white70,
        ),
        errorText: validate ? "Value can't Be Empty" : null,
        errorStyle: const TextStyle(color: Colors.red),
        counterText: "",
        labelText: 'Enter Phone No',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: TextInputType.phone,
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
            /*_phoneNoController.text.isEmpty
                ? validate = true
                : validate = false;*/
            String phone = _phoneNoController.text.trim();

            if (phone.isEmpty) {
              showSnackbarMsg(context, "Please Enter Phone Number");
            } else {
              setState(() {
                isLoading = true;
              });
            }
            /* setState(() {
              isLoading = true;
            });*/
            sendOTP(
              (String verificationId, int? resendToken) {
                setState(() {
                  isLoading = false;
                });
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VerifyOTP(
                        verificationId: verificationId,
                        phoneNumber: '+91$phone')));
              },
            );
            _phoneNoController.clear();
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

  Future<void> sendOTP(
    Function(String verificationId, int? resendToken) onTap,
  ) async {
    String phone = _phoneNoController.text.trim();
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        verificationCompleted: (PhoneAuthCredential credential) {},
        codeSent: onTap,
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('TimeOut');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            showSnackbarMsg(context, "The Provided Number is not Valid!");
          }
        },
      );
    } catch (e) {
      debugPrint('code: ${e.toString()}');
      return;
    }
  }
}
