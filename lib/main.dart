import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:studio/screens/login.dart';
import 'package:studio/screens/register_screen.dart';
import 'auth_store.dart';
import 'constants.dart';
import 'courses_store.dart';
import 'globals.dart';
import 'screens/courses/courses_screen.dart';
import 'screens/courses/edit_course_screen.dart';
import 'screens/login_signup_screen.dart';
import 'screens/subjects/edit_subject_screen.dart';

final auth = AuthStore();
final coursesStore = CoursesStore();

void main() {
  Globals.auth = auth;
  runApp(StudioApp());
}

class StudioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Baloo Paaji 2',
        appBarTheme: AppBarTheme(
          elevation: 0,
          color: kLightGrey,
          textTheme: TextTheme(
            title: TextStyle(
              color: Colors.white,
              fontFamily: 'Baloo Paaji 2',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )
          )
        ),
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        EditCourseScreen.id: (context) => EditCourseScreen(coursesStore, null),
        CoursesScreen.id: (context) => CoursesScreen(coursesStore),
        EditSubjectScreen.id: (context) => EditSubjectScreen(coursesStore, null, null),
        EmailRegisterScreen.id: (context) => EmailRegisterScreen(auth),
        LoginScreen.id: (context) => LoginScreen(auth),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  static String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _checkLogged() async {
    _auth.currentUser().then((user) {
      if (user != null)
        auth.loggedIn(user.uid);
      else
        auth.loggedOut();
    });
  }

  Widget getScreen() {
    if (auth.status == kStatusLoggedOut) return LoginSignupScreen(auth);

    if (auth.status == kStatusLoggedIn) return CoursesScreen(coursesStore);

    return Scaffold(
      body: Container(),
    );
  }

  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
    _checkLogged();
    return getScreen();
  });
}
