// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Timer extends StatelessWidget {
  DocumentSnapshot eventDoc;

  Timer({
    Key? key,
    required this.eventDoc
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("Hier kommt noch ein Timer"),
      color: Colors.green,
    );
  }
}