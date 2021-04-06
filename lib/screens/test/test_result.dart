import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:studio/screens/subjects/subjects_screen.dart';
import 'package:studio/utils/Utils.dart';
import 'package:studio/widgets/buttons.dart';

import '../../constants.dart';
import '../../courses_store.dart';
import '../../models/subject.dart';
import '../../models/test_result.dart';
import '../../services/test_service.dart';
import '../../widgets/circle_progress.dart';
import '../../widgets/curved_bottom_clipper.dart';
import '../courses/course_screen.dart';

class TestResultScreen extends StatefulWidget {
  final CoursesStore store;
  final TestService service;

  TestResultScreen(this.store, this.service);

  @override
  _TestResultScreenState createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen>
    with SingleTickerProviderStateMixin {
  TestResult result;
  AnimationController progressController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    result = widget.service.result();
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animation = Tween<double>(begin: 0, end: result.percentage().toDouble())
        .animate(progressController)
          ..addListener(() {
            setState(() {});
          });
    progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: kContrastColor),
        title: Text(
          widget.store.course.name,
          style: TextStyle(
              color: kTitleColor,
              fontSize: 23,
              fontFamily: "Quicksand",
              fontWeight: FontWeight.w200),
        ),
        titleTextStyle: TextStyle(
            color: kTitleColor,
            fontSize: 23,
            fontFamily: "Quicksand",
            fontWeight: FontWeight.w200),
        backgroundColor: kBackgroundColor,
        leading: Container(),
        /*actions: <Widget>[
          FlatButton(
            child: Icon(
              LineAwesomeIcons.times,
              color: kContrastColor,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CourseScreen(widget.store)));
            },
          )
        ],*/
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Test result',
              style: TextStyle(
                  color: kTitleColor,
                  fontSize: 18,
                  fontFamily: "Quicksand",
                  fontWeight: FontWeight.w200),
            ),
            ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: circle(),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(
              height: widget.service.hasErrors() ? 40 : 0,
            ),
            titlePanel(),
            resultPanel(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: kBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryButton(
                "CLOSE",
                () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubjectsScreen(widget.store)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget circle() {
    var value = animation.value;

    var color = Colors.redAccent;
    if (value > 50) color = Colors.orangeAccent;
    if (value > 70) color = Colors.greenAccent;

    return Stack(
      children: [
        Image.asset(
          "assets/images/result.png",
          height: 160,
          width: 160,
          color: color,
        ),
        Container(
          width: 155,
          height: 155,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
              child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                "%",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: kDarkBlue.withAlpha(0)),
              ),
              Text(
                "${animation.value.toInt()}",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Text(
                "%",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          )),
        ),
      ],
    );
  }

  Widget noErrorsPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Text(
              'All answers are correct, great job!',
              style: TextStyle(
                  color: kTitleColor,
                  fontSize: 18,
                  fontFamily: "Quicksand",
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

        ],
      ),
    );
  }

  Widget titlePanel() {
    var text =
        widget.service.hasErrors() ? "Improve the following subjects:" : "";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget resultPanel() {
    if (!widget.service.hasErrors()) {
      return noErrorsPanel();
    }

    var subjects = widget.service.wrongSubjects(widget.store.subjects);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
          children: subjects
              .map(
                (e) => Card(
                  elevation: 0,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: subjectCard(e),
                      )),
                ),
              )
              .toList()),
    );
  }

  subjectCard(Subject subject) {
    List<Widget> content = [
      Row(
        children: <Widget>[
          Column(
            children: [
              Row(
                children: [
                  Image.asset("assets/images/Bitmap.png", height: 18),
                  Padding(
                    padding: const EdgeInsets.only(left: 7.0),
                    child: Text(
                      subject.name,
                      style: TextStyle(
                          fontSize: 20,
                          height: 1.4,
                          fontFamily: "Quicksand",
                          color: HexColor("5D646B"),
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    /*  widget.service.wrongQuestionsBySubject(subject).forEach((element) {
      content.add(ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: Text(element.text),
      ));
    });*/

    return content;
  }
}
