import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:studio/screens/login.dart';
import 'package:studio/screens/register_screen.dart';
import 'package:studio/utils/Utils.dart';

import '../auth_store.dart';
import '../constants.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen(this.store);

  static String id = 'login_screen';
  final AuthStore store;

  @override
  State<StatefulWidget> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  var loggedIn = false;
  var _loading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AnimationController _controller;
  var versionCode;
  String errorMessage = "";

  Future<FirebaseUser> _handleSignIn() async {
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
    getVersion();
  }

  getVersion() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    var data = await deviceInfoPlugin.iosInfo;
    setState(() {
      versionCode = data.systemVersion;
    });
  }

  Future<FirebaseUser> signInWithApple() async {
    if (Platform.isAndroid) {
      var redirectURL = "";
      var clientID = "com.greentreelabs.studio";
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
      if (appleIdCredential.userIdentifier != null) {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: HexColor("F3F3F5"),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "My Professor",
                  style: TextStyle(
                      fontSize: 23,
                      fontFamily: "Quicksand",
                      color: HexColor("5D646B"),
                      fontWeight: FontWeight.w200),
                ),
                Image.asset(
                  "assets/images/professor-new.png",
                  height: MediaQuery.of(context).size.height / 3.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
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
                            width: MediaQuery.of(context).size.width / 1.26,
                            child: FacebookSignInButton(
                              onPressed: () => fb_email_login(),
                              text: "Join using Facebook",
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
                              text: "Join using Google",
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "nunito",
                                  fontWeight: FontWeight.w600),
                              centered: true,
                              borderRadius: 5,
                              onPressed: () {
                                print('Sign in');
                                setState(() {
                                  _loading = true;
                                });
                                _handleSignIn().then(
                                  (FirebaseUser user) {
                                    print("00000++++++" + user.displayName);
                                    setState(() {
                                      _loading = false;
                                    });
                                    widget.store.loggedIn(user.uid);
                                    //Navigator.pop(context);
                                    //Navigator.of(context).pushReplacementNamed(HomeScreen.id);
                                    //Navigator.pushNamed(context, HomeScreen.id);
                                  },
                                ).catchError((e) => print(e));
                              },
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          //join using apple
                          Platform.isIOS && versionCode >= 13.0 ||
                                  Platform.isAndroid
                              ? Container(
                                  height: 38.0, // 40dp - 2*1dp border
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width / 1.26,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(5.0)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          child: Image.asset(
                                            "assets/images/apple-icon.png",
                                            height: 17,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0),
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
                                  )
                              : Container(),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                color: Colors.black26,
                                width: MediaQuery.of(context).size.width / 2.95,
                                height: 1.5,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "nunito",
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                color: Colors.black26,
                                width: MediaQuery.of(context).size.width / 2.95,
                                height: 1.5,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          //join using email
                          Container(
                            width: MediaQuery.of(context).size.width / 1.26,
                            child: FlatButton(
                              height: 40.5,
                              color: HexColor("E5E5E5"),
                              child: Text(
                                "Join using Email",
                                style: TextStyle(
                                    color: HexColor("1F1F1F"),
                                    fontFamily: "nunito",
                                    fontWeight: FontWeight.w800),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, EmailRegisterScreen.id);
                                /*showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                        backgroundColor: kDarkBlue,
                                        title: Text(
                                          "Login with Email",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: LoginWithEmail(widget.store)))*/
                              },
                            ),
                          ),
                          SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                          text: "Existing user? ",
                        ),
                        TextSpan(
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Quicksand",
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w700),
                          text: "Log In",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Navigator.pushNamed(context, LoginScreen.id);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fb_email_login() async {
    /*final facebookLogin = new FacebookLogin();

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
        print("token " + facebookLoginResult.accessToken.toMap().toString());

        var firebaseUser = await firebaseAuthWithFacebook(
            token: facebookLoginResult.accessToken);
    }*/


    var facebookLogin = FacebookLogin();
    var facebookLoginResult = await facebookLogin.logIn(["email"]);

    final token = facebookLoginResult.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
    final profile = json.decode(graphResponse.body);

    print("profile----" + profile.toString());
    print("profile id-----" + profile["id"].toString());
    print("profile email-----" + profile["email"].toString());
    print("token-----" + token.toString());

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        break;

      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
    }
    var firebaseUser = await firebaseAuthWithFacebook(
        token: facebookLoginResult.accessToken);
  }

  Future<FirebaseUser> firebaseAuthWithFacebook(
      {@required FacebookAccessToken token}) async {
    AuthCredential credential =
        FacebookAuthProvider.getCredential(accessToken: token.token);
    print("Credential --- " + credential.toString());

    FirebaseUser firebaseUser =
        (await _auth.signInWithCredential(credential)).user;

    print("Facebook UserDetail------ /////  " + firebaseUser.displayName.toString());

    return firebaseUser;
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
