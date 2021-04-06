import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import '../constants.dart';

class WhiteButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  WhiteButton(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.white,
      textColor: kDarkBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  PrimaryButton(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: kPrimaryColor,
      textColor: kDarkBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50)),
      child: Text(
        text,
        style: TextStyle(
            color: kTitleColor,
            fontSize: 18,
            fontFamily: "Quicksand",
            fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed,
      padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
    );
  }
}

class AppleButton extends StatelessWidget {
  final Function onPressed;

  AppleButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width / 1.26,
      child: AppleSignInButton(
        style: AppleButtonStyle.black,
        text: "Sign in with Apple",
        textStyle: TextStyle(
            color: Colors.white,
            fontFamily: "nunito",
            fontWeight: FontWeight.w600),
        onPressed: onPressed,
        borderRadius: 5,
        centered: true,
      ),
    );
  }
}
