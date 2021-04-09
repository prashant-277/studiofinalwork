import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:studio/screens/courses/courses_screen.dart';
import 'package:studio/utils/Utils.dart';

import '../../constants.dart';
import '../../courses_store.dart';
import '../../models/course.dart';
import '../../models/subject.dart';
import '../../utils/Utils.dart';
import '../../widgets/course_title.dart';
import '../books_screen.dart';
import '../courses/edit_course_screen.dart';
import '../edit_book_screen.dart';
import '../home_screen.dart';
import '../test/test_home_screen.dart';
import 'edit_subject_screen.dart';
import 'subject_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final CoursesStore store;
  static final id = 'subjects_screen';

  const SubjectsScreen(this.store);

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    widget.store.loadSubjects(widget.store.course.id);
    //widget.store.loadCourse(widget.store.course.id);


    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      Observer(builder: (_) {
        return Scaffold(
          //drawer: MainDrawer(widget.store),
          backgroundColor: kBackground,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: kTitleColor),
            title: CourseTitle(
                widget.store, widget.store.course, kContrastDarkColor),
            backgroundColor: kLightGrey,
            actions: <Widget>[
              PopupMenuButton<int>(
                onSelected: (int) {
                  switch (int) {
                    case kActionEdit:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditCourseScreen(
                                      widget.store, widget.store.course)));
                      break;
                    case kActionDelete:
                      showDialog(
                          context: context,
                          builder: (_) =>
                              AlertDialog(
                                title: Text('Confirm'),
                                content: Text('Do you really want to delete '
                                    'course ${widget.store.course
                                    .name} and all '
                                    'its subjects, notes and questions?'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No'),
                                  ),
                                  FlatButton(
                                    child: Text('Yes'),
                                    textColor: Colors.red,
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await widget.store.deleteCourse(
                                          widget.store.course.id);
                                      Navigator.pushReplacementNamed(context, CoursesScreen.id);
                                    },
                                  )
                                ],
                              ));
                      break;
                    case kActionBooks:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BooksScreen(widget.store)));
                      break;

                    case kActionTest:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TestHomeScreen(widget.store)));
                      break;

                    case kActionResults:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TestHomeScreen(widget.store)));
                      break;
                  }
                },
                offset: Offset(0, 20),
                elevation: 20,
                itemBuilder: (context) =>
                [
                  PopupMenuItem(
                    value: kActionBooks,
                    child: Text(
                      "Books",
                      style: TextStyle(
                        color: kDarkGrey,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: kActionTest,
                    child: Text(
                      "Test",
                      style: TextStyle(
                        color: kDarkGrey,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: kActionResults,
                    child: Text(
                      "Results",
                      style: TextStyle(
                        color: kDarkGrey,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: kActionEdit,
                    child: Text(
                      "Edit course",
                      style: TextStyle(
                        color: kDarkGrey,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: kActionDelete,
                    child: Text(
                      "Delete course",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
                child: Icon(Icons.more_vert),
              ),
            ],
          ),
          floatingActionButton: widget.store.subjects.length == 0
              ? SizedBox()
              : SpeedDial(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              child: Icon(Icons.add, color: Colors.black,),
              children: [
                SpeedDialChild(
                  child: Icon(Icons.class_),
                  backgroundColor: kPrimaryColor,
                  label: 'Add subject',
                  labelStyle: TextStyle(fontSize: 18.0),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditSubjectScreen(
                                    widget.store,
                                    widget.store.course,
                                    null)));
                  },
                ),
                SpeedDialChild(
                  child: Icon(LineAwesomeIcons.book),
                  backgroundColor: kPrimaryColor,
                  label: 'Add book',
                  labelStyle: TextStyle(fontSize: 18.0),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditBookScreen(
                                    widget.store,
                                    widget.store.course,
                                    null)));
                  },
                ),
              ]),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: SubjectItemsView(widget.store, widget.store.course),
                )
              ],
            ),
          ),
        );
      });
}

class SubjectItemsView extends StatefulWidget {
  const SubjectItemsView(this.store, this.course);

  final CoursesStore store;
  final Course course;

  @override
  _SubjectItemsViewState createState() => _SubjectItemsViewState();
}

class _SubjectItemsViewState extends State<SubjectItemsView> {
  @override
  // ignore: missing_return
  Widget build(BuildContext context) => Observer(builder: (_) {
        return ModalProgressHUD(
          color: kLightGrey,
          child: resultWidget(context, widget.store.subjects),
          inAsyncCall: widget.store.isSubjectsLoading /*|| widget.store.isCourseLoading*/,
        );
      });

  resultWidget(BuildContext context, List<Subject> items) {

    if (!widget.store.isSubjectsLoading && items.length == 0) {
      return SingleChildScrollView(
        child: Container(
          //height: MediaQuery.of(context).size.height/3.2,
          padding: EdgeInsets.symmetric(vertical: 20),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(0, 1.2), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              Image(
                image: AssetImage('assets/images/professor-new.png'),
                height: 150,
                width: 150,
              ),
              Column(
                children: [
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width / 2.5,
                    child: Text.rich(
                      TextSpan(
                        text: "${widget.store.course.name}",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Quicksand",
                            color: HexColor("5D646B"),
                            fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                            text: " has no subject yet, let's add some!",
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Quicksand",
                                color: HexColor("5D646B"),
                                fontWeight: FontWeight.w200),
                          ),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  FlatButton(
                    color: kPrimaryColor,
                    textColor: kDarkBlue,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: HexColor("F5A638"),
                            width: 0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(50)),
                    child: Text(
                      "ADD SUBJECTS",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditSubjectScreen(
                                      widget.store, widget.store.course, null)));
                    },
                    padding: EdgeInsets.fromLTRB(30, 12, 30, 12),
                  )
                ],
              )
            ],
          ),
        ),
      );
    }

    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
              child: ListTile(
                onTap: () {
                  widget.store.setSubject(item);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubjectScreen(widget.store, widget.course)));


                },
                trailing: Image(
                  image: AssetImage("assets/images/right_arrow.png"),
                  height: 20,
                ),
                title: Container(
                  child: Text(
                    StringUtils.capitalize(item.name),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: "Quicksand",
                        color: HexColor("#5D646B"),
                        fontSize: 18),
                  ),
                ),
                subtitle: subjectSubtitle(item),
              ),
            ),
          );
        });
  }

  Widget subjectSubtitle(Subject item) {
    if (item.bookTitle == null || item.bookTitle == '')
      return null;

    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Icon(
            LineAwesomeIcons.book,
            size: 18,
            color: HexColor("#5D646B"),
          ),
          Text(
            item.bookTitle,
            style: TextStyle(
                fontWeight: FontWeight.w200,
                fontSize: 14,
                fontFamily: "Nunito",
                fontStyle: FontStyle.italic,
                color: HexColor("#5D646B")),
          )
        ],
      ),
    );
  }
}
