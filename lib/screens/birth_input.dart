import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio/auth_store.dart';
import 'package:studio/main.dart';
import 'package:studio/screens/courses/courses_screen.dart';

class BirthDateScreen extends StatefulWidget {
  static String id = 'birthdate';
  final AuthStore store;
  BirthDateScreen(this.store);
  @override
  _BirthDateScreenState createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime selectedDate;
  DocumentSnapshot snapshot; //Define snapshot

  final _firestore = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _dobController = TextEditingController();

  bool show = false;
  void onTap() {
    show = !show;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.bottomLeft,
                      child: Icon(
                        Icons.arrow_back_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: query.height * 0.03,
                  ),
                  Container(
                    child: Image.asset('assets/images/study.jpeg'),
                  ),
                  SizedBox(
                    height: query.height * 0.08,
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
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
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
                      child: Text("Create Account",
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        _firestore
                            .collection('users')
                            .document(prefs.getString("documentID"))
                            .updateData({
                          "dob": "${selectedDate.toString().split(' ')[0]}"
                        }).then((result) {
                          prefs.remove("documentID");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CoursesScreen(coursesStore)));
                        });
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
                    height: query.height * 0.3,
                  ),
                  Container(
                    height: query.height * 0.25,
                    width: query.width,
                    color: Colors.white60,
                    child: Column(
                      children: [
                        SizedBox(
                          height: query.height * 0.04,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text:
                                      'By tapping create Account, I agree to study Hero ',
                                  style: TextStyle(color: Colors.black87)),
                              TextSpan(
                                  text: "terms",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.black,
                                  )),
                              TextSpan(
                                  text: " and ",
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                              TextSpan(
                                  text: "Privacy policy",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    decoration: TextDecoration.underline,
                                  )),
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: query.height * 0.03,
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            "Why do I need to provide my email and birthday?",
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(
                          height: query.height * 0.005,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Center(
                            child: Text(
                              "We need your email for essential products function like resetting your password .Your birthday lets us customize the problem solving experience for you and stay in compliance with local regulations.",
                              style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 12),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
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
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
}
