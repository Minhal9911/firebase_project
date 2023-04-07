import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    // width: 240,
    //height: 260,
    color: Colors.white,
  );
}

Future<void> showSnackbarMsg(context, String msg) async {
  final snackbar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(6),
    // for margin snackbar behavior should not be fixed
    padding: const EdgeInsets.all(12),
    content: Text(
      msg,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    backgroundColor: Colors.purple,
    shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          width: 0,
          color: Colors.purple,
          // style: BorderStyle.solid,
        )),
    // action: SnackBarAction(label: 'Undo',textColor: Colors.white, onPressed: (){Navigator.of(context).pop();}),
    // onVisible: (){},
    duration: const Duration(milliseconds: 600),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
