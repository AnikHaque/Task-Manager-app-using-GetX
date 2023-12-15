// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isBtnLoading;
  final String buttonText;

  const CustomButton({
    required this.onTap,
    required this.buttonText,
    this.isBtnLoading = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(14.0),
      elevation: 0,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: isBtnLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Loading.. ",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    SizedBox(width: 10),
                    Transform.scale(
                      scale: 0.6,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ],
                )
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12.0),
                  child: Center(
                      child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )),
                ),
        ),
      ),
    );
  }
}
