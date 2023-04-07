import 'package:authentication/email/reusable_widgets/reusable_widget.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../project_screens/list_screen.dart';

class VerifyOTP extends StatefulWidget {
  const VerifyOTP(
      {Key? key, required this.verificationId, required this.phoneNumber})
      : super(key: key);
  final String verificationId;
  final String phoneNumber;

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  final TextEditingController _pinController = TextEditingController();
  final focusNode = FocusNode();

  bool isObscure = true;
  bool isLoading = false;
  String reqOTP = '222222';

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Verify OTP",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
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
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: [
                const Text(
                  'Verification',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Enter the code send to the number",
                  style: TextStyle(color: Colors.white60, fontSize: 17),
                ),
                const SizedBox(height: 30),
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 50),
                verifyOTPField(context),
                const SizedBox(height: 40),
                verifyButton(context),
                const SizedBox(height: 40),
                resendOption(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget verifyOTPField(context) {
    return SizedBox(
      height: 80,
      width: MediaQuery.of(context).size.width,
      child: Pinput(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        length: 6,
        controller: _pinController,
        focusNode: focusNode,
        androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
        listenForMultipleSmsOnAndroid: true,
        defaultPinTheme: const PinTheme(
          height: 50,
          width: 50,
          textStyle: TextStyle(color: Colors.white, fontSize: 25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white38,
          ),
        ),
        /* validator: (value) {
          debugPrint('validate');
          if (value == reqOTP) {
            return null;
          }
          return 'Pin is Incorrect';
        },*/
        /* onClipboardFound: (value){
         debugPrint('onClipboardFound:$value');
         _pinController.setText(value);
        },*/
        /*  focusedPinTheme: PinTheme(
          height: 50,
          width: 50,
          textStyle: TextStyle(color: Colors.black, fontSize: 25),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white70,
            borderRadius: BorderRadius.circular(15),
          ),
        ),*/
        /*submittedPinTheme: PinTheme(
          height: 50,
          width: 50,
          textStyle: TextStyle(color: Colors.black, fontSize: 25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white60,
          ),
        ),*/
      ),
    );
  }

  Widget verifyButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
      ),
      child: ElevatedButton(
        onPressed: () async {
          focusNode.unfocus();
          String otpField = _pinController.text.trim();
          if (otpField.isEmpty) {
            showSnackbarMsg(context, 'Please Enter the Code');
          }
          setState(() {
            isLoading = true;
          });
          await verifyOTP();
          setState(() {
            isLoading = false;
          });
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)))),
        child: isLoading
            ? const SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.purple,
                ),
              )
            : const Text(
                'Verify',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
      ),
    );
  }

  Widget resendOption(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Didn't receive code? ",
          style: TextStyle(color: Colors.white70, fontSize: 17),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {},
          child: const Text(
            "Resend",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    );
  }

  Future<void> verifyOTP() async {
    String otp = _pinController.text.trim();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: otp);
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ListScreen()));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-verification-code") {
        showSnackbarMsg(context, "The code is invalid");
      }
    }
  }
}
