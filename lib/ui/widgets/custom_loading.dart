// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// For loading indicator
Widget loader() {
  return Center(
    child: SpinKitFadingCircle(
      size: 50,
      color: Color(0xFF0C9B4B),
    ),
  );
}
