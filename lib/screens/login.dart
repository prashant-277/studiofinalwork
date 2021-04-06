import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:studio/main.dart';
import 'package:studio/screens/birth_input.dart';
import 'package:studio/screens/courses/courses_screen.dart';
import 'package:studio/screens/loginWithEmail.dart';
import 'package:studio/utils/Utils.dart';

import '../auth_store.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'loginPage';

  const LoginScreen(this.store);

  final AuthStore store;

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  var loggedIn = false;
  final _formKey = GlobalKey<FormState>();

  final _firestore = Firestore.instance;

  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _pswdCtrl = TextEditingController();
  var _loading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AnimationController _controller;
  var versionCode;
  String errorMessage = "";

  String email = '';

  String password = '';

  Future<FirebaseUser> _handleSignIn() async {
    _auth.app.options.catchError((error) {
      print("error---->$error");
    });
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;

    print("signed in " + user.displayName);
    return user;
  }

  Animation<double> opacity;

  @override
  void initState() {
    super.initState();
    //  precacheImage(new AssetImage('assets/images/bg-login-2.jpg'), context);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  applelogin() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    var data = await deviceInfoPlugin.iosInfo;
    setState(() {
      versionCode = data.systemVersion;
    });
  }

  Future<FirebaseUser> signInWithApple() async {
    if (Platform.isAndroid) {
      var redirectURL = "";
      var clientID = "";
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
              clientId: clientID, redirectUri: Uri.parse(redirectURL)));
      final oAuthProvider = OAuthProvider(providerId: 'apple.com');
      final credential = oAuthProvider.getCredential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );
    } else {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (appleIdCredential.userIdentifier != null) {
        // await FlutterSecureStorage()
        //     .write(key: "userId", value: appleIdCredential.userIdentifier);
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    CoursesScreen(coursesStore)));
      }
      print("apple---->${appleIdCredential}");
    }

    // final authResult =
    // await SignInUtil.firebaseAuth.signInWithCredential(credential);
    // return authResult.user;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool show = true;

  void onTap() {
    show = !show;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(color: kTitleColor),
        title: Text(
          "Login",
          style: TextStyle(
              fontSize: 23,
              fontFamily: "Quicksand",
              color: HexColor("5D646B"),
              fontWeight: FontWeight.w200),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              // height: MediaQuery.of(context).size.height,
              color: HexColor("F3F3F5"),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: query.height * 0.04,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      controller: _emailCtrl,
                      validator: (value) =>
                          value.isEmpty ? 'Please enter email' : null,
                      onChanged: (value) {
                        setState(() => email = value);
                      },
                      maxLines: 1,
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
                    height: query.height * 0.03,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      controller: _pswdCtrl,
                      textAlign: TextAlign.start,
                      obscureText: show,
                      validator: (value) =>
                          value.isEmpty ? 'Please enter password' : null,
                      onChanged: (value) {
                        setState(() => password = value);
                      },
                      maxLines: 1,
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
                    height: query.height * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 15,
                            fontFamily: "Quicksand",
                            color: HexColor("5D646B"),
                            fontWeight: FontWeight.w500),
                      ),
                      Container(
                        width: query.width * 0.40,
                        height: query.height * 0.06,
                        child: ElevatedButton(
                          child: Text(
                            "Log in",
                            style: TextStyle(
                                fontFamily: "Quicksand",
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              print("done");
                              loginWithEmail(false);
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
                    ],
                  ),
                  SizedBox(
                    height: query.height * 0.03,
                  ),
                  Text(
                    "OR",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 15,
                        fontFamily: "Quicksand",
                        color: HexColor("5D646B"),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: query.height * 0.01,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    child: Card(
                      elevation: 0.3,
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 18),
                            Container(
                                height: 38.0, // 40dp - 2*1dp border
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                width: MediaQuery.of(context).size.width / 1.26,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(5.0)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Image.asset(
                                          "assets/images/apple-icon.png",
                                          height: 17,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          "Join with Apple",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "nunito",
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: signInWithApple,
                                  color: Colors.black,
                                )

                                /*SignInWithAppleButton(
                                    style: SignInWithAppleButtonStyle.black,
                                    onPressed: signInWithApple,
                                    text: 'Join with Apple',
                                    height: 40,

                                  ),*/
                                ),
                            SizedBox(height: 8),

                            Container(
                              width: MediaQuery.of(context).size.width / 1.26,
                              child: FacebookSignInButton(
                                onPressed: () => fb_email_login(),
                                text: "Log in with Facebook",
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "nunito",
                                    fontWeight: FontWeight.w600),
                                centered: true,
                                borderRadius: 5,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            //Join using Google
                            Container(
                              width: MediaQuery.of(context).size.width / 1.26,
                              child: GoogleSignInButton(
                                text: "    Log in with Google",
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "nunito",
                                    fontWeight: FontWeight.w600),
                                centered: true,
                                borderRadius: 5,
                                onPressed: () {
                                  /*print('Sign in');
                                  setState(() {
                                    _loading = true;
                                  });
                                  _handleSignIn().then((FirebaseUser user) {
                                    print(user.displayName);
                                    setState(() {
                                      _loading = false;
                                    });
                                    widget.store.loggedIn(user.uid);
                                    //Navigator.of(context).pushReplacementNamed(HomeScreen.id);
                                    //Navigator.pushNamed(context, HomeScreen.id);
                                  }).catchError((e) => print(e));*/
                                  print('Sign in');
                                  setState(() {
                                    _loading = true;
                                  });
                                  _handleSignIn().then((FirebaseUser user) {
                                    print("user name----" + user.displayName);
                                    setState(() {
                                      _loading = false;
                                    });
                                    widget.store.loggedIn(user.uid);
                                    Navigator.pop(context);
                                    //Navigator.of(context).pushReplacementNamed(HomeScreen.id);
                                    //Navigator.pushNamed(context, HomeScreen.id);
                                  }).catchError((e) => print(e));
                                },
                              ),
                            ),
                            SizedBox(height: 8),

                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Quicksand",
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                      text: "No account yet? ",
                                    ),
                                    TextSpan(
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Quicksand",
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w700),
                                      text: "Sign Up",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          Navigator.pop(context);
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 18),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Container(
                                //   color: Colors.black26,
                                //   width:
                                //       MediaQuery.of(context).size.width / 2.95,
                                //   height: 1.5,
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 8.0),
                                //   child: Text(
                                //     "OR",
                                //     style: TextStyle(
                                //         color: Colors.black,
                                //         fontFamily: "nunito",
                                //         fontWeight: FontWeight.w600),
                                //   ),
                                // ),
                                // Container(
                                //   color: Colors.black26,
                                //   width:
                                //       MediaQuery.of(context).size.width / 2.95,
                                //   height: 1.5,
                                // )
                              ],
                            ),

                            //join using email
                            // Container(
                            //   width: MediaQuery.of(context).size.width / 1.26,
                            //   child: FlatButton(
                            //     height: 40.5,
                            //     color: HexColor("E5E5E5"),
                            //     child: Text(
                            //       "Log in with Email",
                            //       style: TextStyle(
                            //           color: HexColor("1F1F1F"),
                            //           fontFamily: "nunito",
                            //           fontWeight: FontWeight.w800),
                            //     ),
                            //     onPressed: () {
                            //       showDialog(
                            //           context: context,
                            //           builder: (_) => AlertDialog(
                            //               backgroundColor: kDarkBlue,
                            //               title: Text(
                            //                 "Login with Email",
                            //                 style:
                            //                     TextStyle(color: Colors.white),
                            //               ),
                            //               content:
                            //                   LoginWithEmail(widget.store)));
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //     padding: const EdgeInsets.all(10.0),
                  //     child: Text.rich(
                  //       TextSpan(
                  //         text: 'Sign Up? ',
                  //         style: TextStyle(
                  //             color: Colors.black,
                  //             fontFamily: "nunito",
                  //             fontSize: 15,
                  //             fontWeight: FontWeight.w700),
                  //         children: <TextSpan>[
                  //           TextSpan(
                  //             text: 'Log In',
                  //             style: TextStyle(
                  //                 color: Colors.black,
                  //                 fontFamily: "nunito",
                  //                 fontSize: 15,
                  //                 decoration: TextDecoration.underline,
                  //                 fontWeight: FontWeight.w700),
                  //           ),
                  //           // can add more TextSpans here...
                  //         ],
                  //       ),
                  //     ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fb_email_login() async {
    final facebookLogin = new FacebookLogin();

    final facebookLoginResult =
        await facebookLogin.logIn(['email', 'public_profile']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        break;

      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        break;

      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        print("token " + facebookLoginResult.accessToken.token);

        var firebaseUser = await firebaseAuthWithFacebook(
            token: facebookLoginResult.accessToken);
    }
  }

  Future<FirebaseUser> firebaseAuthWithFacebook(
      {@required FacebookAccessToken token}) async {
    AuthCredential credential =
        FacebookAuthProvider.getCredential(accessToken: token.token);
    FirebaseUser firebaseUser =
        (await _auth.signInWithCredential(credential)).user;
    print("Facebook UserDetail------ /////  " +
        firebaseUser.displayName.toString());
    Navigator.pop(context);

    return firebaseUser;
  }

  Future<String> getFirebaseData(String email) async {
    String data;
    await _firestore.collection("users").getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        print(result.data['email']);
        print(result.data['pass']);
        print(result.data['dob']);
        if (result.data['email'] == email) {
          if (result.data['dob'] == null) {
            data = "true.::.${result.documentID}";
          } else {
            data = "false.::.${result.documentID}";
          }
        }
      });
    });
    return data;
  }

  void loginWithEmail(bool isRegister) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _emailCtrl.text, password: _pswdCtrl.text)
        .then((signedInUser) {
      getFirebaseData(_emailCtrl.text).then((value) async {
        if (value.contains("true")) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("documentID", value.split(".::.")[1]);
          //Navigation to dob screen
          Navigator.pushNamed(
            context,
            BirthDateScreen.id,
          );
        } else {
          //Navigation to home screen
          Navigator.pop(context);
          widget.store.loggedIn(signedInUser.user.uid);

          if (signedInUser != null) {
            Fluttertoast.showToast(msg: "Login Successfully");
            Navigator.pushNamed(context, '/homepage');
            print("null");
          }
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

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 80),
      child: Text(
        'Studio',
        style: TextStyle(
            color: Colors.white, fontSize: 60, fontWeight: FontWeight.w600),
      ),
    );
  }
}
