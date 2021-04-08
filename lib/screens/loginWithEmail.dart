import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:studio/auth_store.dart';
import 'package:studio/screens/register_screen.dart';
import 'package:studio/widgets/buttons.dart';

class LoginWithEmail extends StatefulWidget {
  LoginWithEmail(this.store);

  final AuthStore store;

  @override
  _LoginWithEmailState createState() => _LoginWithEmailState();
}

class _LoginWithEmailState extends State<LoginWithEmail> {
  final _firestore = Firestore.instance;

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  var _loading = false;



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  autocorrect: true,
                  autofocus: true,
                  maxLines: 1,
                  style: TextStyle(color: Colors.white),
                  validator: (value) => value.isEmpty ? 'Enter email' : null,
                  onChanged: (value) {
                    setState(() => email = value);
                  },
                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.white)),
                ),
                TextFormField(
                  controller: passwordController,
                  autocorrect: true,
                  autofocus: true,
                  maxLines: 1,
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  validator: (value) => value.isEmpty ? 'Enter password' : null,
                  onChanged: (value) {
                    setState(() => password = value);
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.vpn_key_rounded,
                        color: Colors.white,
                      ),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: WhiteButton("Sign In", () {
                  if (_formKey.currentState.validate()) {
                    print("done");
                    Navigator.pop(context);
                    loginWithEmail(false);
                  }
                }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 15.0),
                child: WhiteButton(
                  "Register",
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, EmailRegisterScreen.id);

                    // if (_formKey.currentState.validate()) {
                    //   print("done");
                    //   loginWithEmail(true);
                    // }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void loginWithEmail(bool isRegister) {
    isRegister
        ? FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        : FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .then((signedInUser) {
            _firestore.collection('users').add({
              'email': emailController.text,
              'pass': emailController.text,
            }).then((value) {
              Navigator.pop(context);
              widget.store.loggedIn(signedInUser.user.uid);

              if (signedInUser != null) {
                isRegister
                    ? Fluttertoast.showToast(msg: "Register Successfully")
                    : Fluttertoast.showToast(msg: "Login Successfully");
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
}
