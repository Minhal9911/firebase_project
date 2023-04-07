import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:authentication/email/reusable_widgets/reusable_widget.dart';
import 'package:authentication/project_screens/list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final progressNotifier = ValueNotifier<double>(0);

  File? profilePic;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imageField(),
                const SizedBox(height: 20),
                nameTextField(),
                const SizedBox(height: 10),
                emailTextField(),
                const SizedBox(height: 10),
                ageTextField(),
                const SizedBox(height: 25),
                showElevatedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget imageField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.purple),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: () {
          showPop();
        },
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white70,
          backgroundImage: (profilePic != null ? FileImage(profilePic!) : null),
        ),
      ),
    );
  }

  void showPop() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              height: 200,
              width: 200,
              // margin: const EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.pink.shade400,
                    Colors.purple,
                    Colors.blue.shade600,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      imagePickOption(ImageSource.camera)
                          .then((value) => Navigator.of(context).pop());
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(5),
                    ),
                    icon: const Icon(Icons.camera, color: Colors.red),
                    label: const Text(
                      "Camera",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      imagePickOption(ImageSource.gallery)
                          .then((value) => Navigator.of(context).pop());
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(5),
                    ),
                    icon: const Icon(Icons.image, color: Colors.red),
                    label: const Text(
                      "Gallery",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget nameTextField() {
    return TextField(
      controller: _nameController,
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

  Widget ageTextField() {
    return TextField(
      controller: _ageController,
      enableSuggestions: true,
      autocorrect: true,
      autofocus: false,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      maxLength: 2,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.person_outline,
          color: Colors.white70,
        ),
        labelText: "Enter Age",
        counterText: '',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: TextInputType.number,
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
        labelText: "Enter Email Address",
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

  Widget showElevatedButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
      ),
      child: ElevatedButton(
        onPressed: !isLoading
            ? () async {
                String name = _nameController.text.trim();
                String email = _emailController.text.trim();
                String age = _ageController.text.trim();

                if (name.isEmpty) {
                  showSnackbarMsg(context, "Please fill the name");
                } else if (email.isEmpty) {
                  showSnackbarMsg(context, "Please fill the email");
                } else if (age.isEmpty) {
                  showSnackbarMsg(context, 'Please fill the age');
                } else if (profilePic == null) {
                  showSnackbarMsg(context, 'Please select the Image');
                } else {
                  setState(() {
                    isLoading = true;
                  });
                }
                log('Loading');
                await saveUser()
                    .then((value) => Navigator.of(context)
                        .popUntil((route) => route.isFirst))
                    .then((value) => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const ListScreen())));
                setState(() {
                  isLoading = false;
                });
                _nameController.clear();
                _emailController.clear();
                _ageController.clear();
              }
            : null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 50,
                width: 50,
                child: ValueListenableBuilder<double>(
                    valueListenable: progressNotifier,
                    builder: (context, value, child) {
                      return CircularPercentIndicator(
                        radius: 24,
                        lineWidth: 4,
                        percent: value * 0.01,
                        animation: true,
                        // animationDuration: 1000,
                        center: Text("${value.toInt()}%",
                            style: const TextStyle(color: Colors.purple)),
                        progressColor: Colors.purple,
                      );
                    }),
              )
            : const Text(
                "Save",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
      ),
    );
  }

  Future<void> saveUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String ageString = _ageController.text.trim();

    int age = int.parse(ageString);

    // String id = DateTime.now().toString();
    String uuid = const Uuid().v1().toString();

    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("profilePicture")
        .child(const Uuid().v1())
        .putFile(profilePic!);
    StreamSubscription taskSubscription =
        uploadTask.snapshotEvents.listen((snapshot) {
      double percentage = snapshot.bytesTransferred / snapshot.totalBytes * 100;
      progressNotifier.value = percentage;
      log(percentage.toString());
    }); // realtime data update
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    taskSubscription.cancel();

    Map<String, dynamic> userData = {
      "name": name,
      "email": email,
      "age": age,
      "id": uuid,
      "profilePic": downloadUrl,
      "samplearray": [name, email, age],
    };
    try {
      CollectionReference userInfo =
          FirebaseFirestore.instance.collection('users');
      userInfo
          .doc(uuid)
          .set(userData)
          .then((value) => debugPrint("The value is saved"))
          .catchError((error) => debugPrint('Error:$error'));
    } catch (e) {
      debugPrint('error:$e');
    }
  }

  Future<void> imagePickOption(ImageSource imagePicker) async {
    XFile? selectedImage = await _picker.pickImage(source: imagePicker);
    if (selectedImage != null) {
      // File convertedFile = File(selectedImage.path);
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: selectedImage.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.purple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            statusBarColor: Colors.purple,
            backgroundColor: Colors.purple.shade300,
            activeControlsWidgetColor: Colors.purple,
            showCropGrid: false,
          ),
        ],
      );
      if (croppedFile != null) {
        File convertFile = File(croppedFile.path);
        setState(() {
          profilePic = convertFile;
        });
      }
      log('Image Selected');
    } else {
      log('No image selected');
    }
  }
}
