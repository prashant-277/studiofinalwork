import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:studio/auth_store.dart';
import 'package:studio/constants.dart';
import 'package:studio/screens/drawer/WebViewContainer.dart';
import 'package:studio/screens/login.dart';
import 'package:studio/screens/login_signup_screen.dart';

class EmailRegisterScreen extends StatefulWidget {
  static String id = 'registerPage';
  final AuthStore store;

  EmailRegisterScreen(this.store);

  @override
  _EmailRegisterScreenState createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  DateTime selectedDate;
  final _firestore = Firestore.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _pwdCtrl = TextEditingController();
  TextEditingController _lastNameCtrl = TextEditingController();
  TextEditingController _firstNameCtrl = TextEditingController();
  TextEditingController _dobController = TextEditingController();

  bool show = true;

  void onTap() {
    show = !show;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: query.height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/app/logo.png",
                        height: 23,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: query.height * 0.09,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      controller: _emailCtrl,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(new RegExp(r" "))
                      ],
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: "WorkSansLight",
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: query.height * 0.02,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      controller: _pwdCtrl,
                      textAlign: TextAlign.start,
                      obscureText: show,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          color: Colors.grey,
                          icon: !show
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                          onPressed: () {
                            onTap();
                          },
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: "WorkSansLight",
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: query.height * 0.02,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      controller: _firstNameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: "WorkSansLight",
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'First Name',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: query.height * 0.02,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      controller: _lastNameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: "WorkSansLight",
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Last Name',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: query.height * 0.02,
                  ),
                  InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: IgnorePointer(
                      child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: TextFormField(
                          textAlign: TextAlign.start,
                          controller: _dobController,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                )),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                )),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontFamily: "WorkSansLight",
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: selectedDate != null
                                ? "${selectedDate.toString().split(' ')[0]}"
                                : "Birth Date",
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: query.height * 0.06,
                  ),
                  Container(
                    width: query.width * 0.9,
                    height: query.height * 0.06,
                    child: ElevatedButton(
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                            fontFamily: "Quicksand",
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          print("done");
                          if (_emailCtrl.text.isEmpty) {
                            Fluttertoast.showToast(msg: "Please Enter Email.");
                          } else if (_pwdCtrl.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Please Enter Password.");
                          } else if (_firstNameCtrl.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Please Enter First Name.");
                          } else if (_lastNameCtrl.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Please Enter Last Name.");
                          } else if (_dobController.text.isEmpty) {
                            Fluttertoast.showToast(msg: "Please enter DOB.");
                          } else {
                            loginWithEmail(true);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.yellow[700],
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: query.height * 0.06,
                  ),
                  Container(
                    height: query.height * 0.23,
                    width: query.width,
                    color: Colors.white60,
                    child: Column(
                      children: [
                        SizedBox(
                          height: query.height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Existing User? ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Quicksand",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, LoginScreen.id);
                              },
                              child: Text(
                                "Log in",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Quicksand",
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: query.height * 0.03,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14),
                                    text:
                                        "By tapping create Account, I agree to study Hero\n",
                                  ),
                                  TextSpan(
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                    text: " Terms",
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        _handleURLButtonPress(
                                            context,
                                            'https://www.multipz.com/mobile-app-development',
                                            'Terms of use');
                                      },
                                  ),
                                  TextSpan(
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14),
                                    text: " and",
                                  ),
                                  TextSpan(
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                    text: " Privacy Policy",
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        _handleURLButtonPress(
                                            context,
                                            'https://www.multipz.com/mobile-app-development',
                                            'Privacy policy');
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate != null ? selectedDate : DateTime.now(),
      firstDate: DateTime(1900, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void loginWithEmail(bool isRegister) {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _emailCtrl.text, password: _pwdCtrl.text)
        .then((signedInUser) {
      _firestore.collection('users').add({
        'name': '${_firstNameCtrl.text} ${_lastNameCtrl.text}',
        'email': _emailCtrl.text,
        'pass': _pwdCtrl.text,
        'dob': selectedDate.toString().split(' ')[0]
      }).then((value) {
        Navigator.pop(context);
        widget.store.loggedIn(signedInUser.user.uid);

        if (signedInUser != null) {
          Fluttertoast.showToast(msg: "Register Successfully");
          Navigator.pushNamed(context, '/homepage');
          print("null");
        } else {}
      }).catchError((e) {
        if (e is PlatformException) {
          Fluttertoast.showToast(msg: e.message);
          print(e.toString());
        }
      });
    }).catchError((e) {
      if (e is PlatformException) {
        Fluttertoast.showToast(msg: e.message);
        print(e.toString());
      }
    });
  }

  void _handleURLButtonPress(BuildContext context, String url, String tabName) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewContainer(url, tabName)));
  }
}