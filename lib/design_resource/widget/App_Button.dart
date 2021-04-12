import 'package:flutter/material.dart';


class AppButton extends StatelessWidget {

  final String title;
  final Color color;
  final Function onPressed;

  AppButton({this.title,this.onPressed,this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:onPressed,
      style: ElevatedButton.styleFrom(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(25.0)
        ),
        primary: color,
        textStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      child:Container(
        height: 50.0,
        child:Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18.0, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),
    );
  }
}
