import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:authentication/project_screens/entry_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../email/screens/signin.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);

  File? profilePic;
  bool isLoading = false;

  /* final Stream<QuerySnapshot> _userStream =
      FirebaseFirestore.instance.collection('users').snapshots();*/

  // Filters

/*  final Stream<QuerySnapshot> _userStream =      FirebaseFirestore.instance.collection('users').where("age",isGreaterThanOrEqualTo: 25).snapshots();*/
  /*final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .where("age", whereIn: [24, 27, 35]).snapshots();*/
  /*final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .where("age", whereNotIn: [24, 27, 35]).snapshots();*/
  /* final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .where("samplearray", arrayContains:"raza@gmail.com")
      .snapshots();*/
  /* final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .where("samplearray", arrayContainsAny:[25,'Minhal'])
      .snapshots();*/
  final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .orderBy('age', descending: false)
      .snapshots();

  /* final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      // .limit(3)
      .where('age', isGreaterThanOrEqualTo: 24)
      .orderBy('age', descending: true)
      .snapshots();*/ // we can use where and orderBy both same time.


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Firebase List'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_outlined, size: 25)),
          IconButton(
              onPressed: () {
                logOut();
              },
              icon: const Icon(
                Icons.exit_to_app,
                size: 30,
              )),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          bool result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Are You Sure?"),
                  content: const Text("Do You Want To Exit !"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('No', style: TextStyle(fontSize: 18)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Yes', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                );
              });
          return Future.value(result);
        },
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.pink.shade400,
                    Colors.purple,
                    Colors.blue.shade600,
                  ])),
          child: StreamBuilder<QuerySnapshot>(
            stream: _userStream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userMap =
                          snapshot.data.docs[index].data()
                          as Map<String, dynamic>;
                          return Card(
                            color: Colors.transparent,
                            elevation: 0,
                            child: ListTile(
                              leading: leadingImage(context, userMap),
                              title: Text(
                                userMap['name'] + "  (Age-:${userMap['age']})",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              subtitle: Text(
                                userMap['email'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              trailing: showTrailingOptions(context, userMap),
                            ),
                          );
                        }),
                  );
                } else {
                  return const Center(child: Text("No data"));
                }
              } else {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EntryScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget leadingImage(context, userMap) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: () {
          imagePop(userMap);
        },
        child: CircleAvatar(
          radius: 24,
          child: CachedNetworkImage(
            imageUrl: userMap['profilePic'],
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    /* colorFilter:
                        const ColorFilter.mode(Colors.green, BlendMode.colorBurn),*/
                  ),
                ),
              );
            },
            placeholder: (context, url) {
              return const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              );
            },
            errorWidget: (context, url, error) {
              return const Icon(Icons.error);
            },
          ),
        ),
      ),
    );
  }

  void imagePop(Map<String, dynamic> userMap) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetAnimationCurve: Curves.easeInOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 220,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.pink.shade400,
                          Colors.purple,
                          Colors.blue.shade600,
                        ]),
                  ),
                  child: InkWell(
                      onTap: () async {
                        showImagePickerOptions(userMap);

                        await uploadTask(userMap);
                      },
                      child: CachedNetworkImage(
                        imageUrl: userMap['profilePic'],
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            // width: 110,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0)),
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        placeholder: (context, url) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const Icon(Icons.error);
                        },
                      )
                    /*: ValueListenableBuilder<double>(
                            valueListenable: progressNotifier,
                            builder: (context, value, child) {
                              return CircularPercentIndicator(
                                radius: 80.0,
                                lineWidth: 12.0,
                                animation: true,
                                percent: value * 0.01,
                                center: Text(
                                  "${value.toInt()}%",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20.0),
                                ),
                                footer: const Text(
                                  "Uploading",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 15.0),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.purple,
                              );
                            }),*/
                  ),
                ),
                Container(
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0)),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.pink.shade400,
                            Colors.purple,
                            Colors.blue.shade600,
                          ])),
                  /*child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chat, color: Colors.white)),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.call, color: Colors.white)),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.video_call,
                              color: Colors.white)),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                          )),
                    ],
                  ),*/
                ),
              ],
            ),
          );
        });
  }

  Widget showTrailingOptions(BuildContext context,
      Map<String, dynamic> userMap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: () {
              showEditDialog(context, userMap);
            },
            icon: const Icon(Icons.edit, color: Colors.white60)),
        IconButton(
          onPressed: () {
            try {
              CollectionReference userInfo =
              FirebaseFirestore.instance.collection('users');
              userInfo
                  .doc(userMap['id'])
                  .delete()
                  .then((value) => debugPrint("The value is saved"))
                  .catchError((error) => debugPrint('Error:$error'));
            } catch (e) {
              debugPrint('error:$e');
            }
            // deleteList();
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  void showEditDialog(BuildContext context, Map<String, dynamic> userMap) {
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
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 0, top: 25),
              height: 260,
              margin: const EdgeInsets.only(top: 50),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  nameTextField(userMap['name']),
                  const SizedBox(height: 10),
                  emailTextField(userMap['email']),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 38,
                        width: 80,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.purple),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 38,
                        width: 80,
                        child: ElevatedButton(
                          onPressed: !isLoading
                              ? () async {
                            setState(() {
                              isLoading = true;
                            });

                            await updateDialog(userMap).then(
                                    (value) => Navigator.of(context).pop());
                            setState(() {
                              isLoading = false;
                            });
                          }
                              : null,
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.purple),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            height: 36,
                            width: 36,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                              : const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  void showImagePickerOptions(Map<String, dynamic> userMap) {
    showDialog(
        context: context,
        barrierDismissible: true,
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

  Widget nameTextField(String name) {
    _nameController.text = name;
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
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: TextInputType.name,
    );
  }

  Widget emailTextField(String email) {
    _emailController.text = email;
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
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Future<void> updateDialog(Map<String, dynamic> userMap) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String uuid = userMap["id"];

    Map<String, dynamic> userData = {
      "name": name,
      "email": email,
      'id': uuid,
      // "profilePic": downloadUrl,
    };

    try {
      CollectionReference userInfo =
      FirebaseFirestore.instance.collection('users');
      userInfo.doc(uuid).update(userData);
      debugPrint("The value is saved");
    } catch (e) {
      debugPrint('error:$e');
    }
  }

  Future<void> uploadTask(Map<String, dynamic> userMap) async {
    String uuid = userMap["id"];

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
      'id': uuid,
      "profilePic": downloadUrl,
    };
    try {
      CollectionReference userInfo =
      FirebaseFirestore.instance.collection('users');
      userInfo.doc(uuid).update(userData);
      debugPrint("The value is saved");
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

  Future<void> logOut() async {
    await FirebaseAuth.instance
        .signOut()
        .then(
            (value) => Navigator.of(context).popUntil((route) => route.isFirst))
        .then((value) =>
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignInScreen())));
  }
}
