import 'package:authentication/email/screens/signin.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../reusable_widgets/reusable_widget.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cPasswordController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.pink.shade400,
                Colors.purple,
                Colors.blue.shade600,
              ]),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                nameTextField(),
                const SizedBox(height: 20),
                emailTextField(),
                const SizedBox(height: 20),
                passwordTextField(context),
                const SizedBox(height: 20),
                cPasswordTextField(context),
                const SizedBox(height: 20),
                signUpButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget nameTextField() {
    return TextField(
      controller: _userNameController,
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
        labelText: "Enter UserName",
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: TextInputType.name,
    );
  }

  Widget emailTextField() {
    return TextField(
      controller: _emailController,
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
        labelText: "Enter Email Id",
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
      controller: _passwordController,
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

  Widget cPasswordTextField(BuildContext context) {
    return TextField(
      controller: _cPasswordController,
      obscuringCharacter: '*',
      obscureText: true,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Colors.white70,
        ),
        labelText: 'Confirm Password',
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

  Widget signUpButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
      ),
      child: ElevatedButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            await createAccount();
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
                  'SIGN UP',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )),
    );
  }

  Future<void> createAccount() async {
    String email = _emailController.text.trim();
    String userName = _userNameController.text.trim();
    String password = _passwordController.text.trim();
    String cPassword = _cPasswordController.text.trim();

    _emailController.clear();
    _userNameController.clear();
    _passwordController.clear();
    _cPasswordController.clear();

    if (email.isEmpty ||
        userName.isEmpty ||
        password.isEmpty ||
        cPassword.isEmpty) {
      showSnackbarMsg(context, 'Please fill the details!');
    } else if (password != cPassword) {
      showSnackbarMsg(context, 'Password do not match!');
    } else {
      try {
        // final credential =
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email,
              password: password,
            )
            .then((value) => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                ));
        /*if (credential.user != null) { // When we use credential
          Navigator.of(context).pop();
        }*/
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showSnackbarMsg(context, 'Week password');
        } else if (e.code == 'email-already-in-use') {
          showSnackbarMsg(context, 'This account already exists');
        }
      } catch (e) {
        debugPrint('$e');
      }
    }
  }
}
