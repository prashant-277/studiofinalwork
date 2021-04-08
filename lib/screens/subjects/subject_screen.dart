import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

import '../../constants.dart';
import '../../courses_store.dart';
import '../../models/course.dart';
import '../../utils/Utils.dart';
import '../notes/edit_note_screen.dart';
import '../notes/notes_screen.dart';
import '../questions/edit_question_screen.dart';
import '../questions/questions_screen.dart';
import 'edit_subject_screen.dart';
import 'package:intl/intl.dart';

class SubjectScreen extends StatefulWidget {
  SubjectScreen(this.store, this.course);

  final Course course;
  final CoursesStore store;
  static final id = 'subject_screen';

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int currentTab = kTabNotes;
  int currentMode = kModeList;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            iconTheme: IconThemeData(color: kTitleColor),
            centerTitle: true,elevation: 3,
            bottom: TabBar(
              controller: _tabController,
              labelColor: HexColor("#5D646B"),
              indicatorColor: HexColor("#5D646B"),
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: false,
              onTap: (index) {
                setState(() {
                  currentTab = index;
                });
              },
              tabs: <Widget>[
                Tab(
                  child: Text("  " + 'Keynotes' + "  ",
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Quicksand",
                          color: HexColor("#5D646B"),
                          fontWeight: FontWeight.w500)),
                  /*icon: Icon(
                    LineAwesomeIcons.edit,
                    color: currentTab == kTabNotes
                        ? kPrimaryColor
                        : Colors.blueGrey[800],
                  ),*/
                ),
                Tab(
                  child: Text("  " + 'Questions' + "  ",
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Quicksand",
                          color: HexColor("#5D646B"),
                          fontWeight: FontWeight.w500)),
                  /*icon: Icon(
                    LineAwesomeIcons.question,
                    color: currentTab == kTabQuestions
                        ? kPrimaryColor
                        : Colors.blueGrey[800],
                  ),*/
                ),
                /* Tab(
                  child: Text("Mindmap",
                      style: TextStyle(
                          color: kTitleColor,
                          fontSize: 15,
                          fontFamily: "Quicksand",
                          fontWeight: FontWeight.w200)),
                  */ /*icon: Icon(
                    LineAwesomeIcons.project_diagram,
                    color: currentTab == kTabMindmap
                        ? kPrimaryColor
                        : Colors.blueGrey[800],
                  ),*/ /*
                ),*/
              ],
            ),
            title: Text(widget.store.subject.name,
                style: TextStyle(
                    color: kTitleColor,
                    fontSize: 23,
                    fontFamily: "Quicksand",
                    fontWeight: FontWeight.w200)),
            actions: <Widget>[
              PopupMenuButton<int>(
                onSelected: (int) {
                  switch (int) {
                    case kActionEdit:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditSubjectScreen(
                                  widget.store,
                                  widget.course,
                                  widget.store.subject)));
                      break;
                    case kActionDelete:
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: Text('Confirm'),
                                content: Text('Do you really want to delete '
                                    'subject ${widget.store.subject.name} and all '
                                    'its notes and questions?'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Yes'),
                                    textColor: Colors.red,
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await widget.store.deleteSubject(
                                          widget.store.subject.id,
                                          widget.course.id);
                                      Navigator.pop(context);
                                      widget.store
                                          .loadSubjects(widget.course.id);
                                    },
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No'),
                                  ),
                                ],
                              ));
                      break;
                    case kActionSlider:
                      setState(() {
                        currentMode = kModeCarousel;
                      });
                      break;

                    case kActionList:
                      setState(() {
                        currentMode = kModeList;
                      });
                      break;
                  }
                },
                offset: Offset(0, 20),
                elevation: 20,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: kActionList,
                    child: Row(
                      children: [
                        Icon(
                          LineAwesomeIcons.bars,
                          color: HexColor("#5D646B")
                        ),
                        SizedBox(width: 5,),
                        new Text('List View',style: TextStyle(
                            fontFamily: "Quicksand",
                            color: HexColor("#5D646B")
                        ))
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: kActionSlider,
                    child: Row(
                      children: [
                        Icon(
                          LineAwesomeIcons.copy,
                          color: HexColor("#5D646B")
                        ),
                        SizedBox(width: 5,),
                        new Text('Slide view',style: TextStyle(
                            fontFamily: "Quicksand",
                            color: HexColor("#5D646B")
                        ))
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: kActionEdit,
                    child: Row(
                      children: [
                        new Icon(
                          Icons.edit,
                          color: HexColor("#5D646B")
                        ),
                        SizedBox(width: 5,),
                        new Text('Edit subject',style: TextStyle(
                            fontFamily: "Quicksand",
                            color: HexColor("#5D646B")
                        ))
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: kActionDelete,
                    child: Row(
                      children: [
                        new Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        SizedBox(width: 5,),
                        new Text(
                          'Delete subject',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Icon(Icons.more_vert),
              ),
              /*FlatButton(
                child: Icon(LineAwesomeIcons.ellipsis_v),
                onPressed: () {

                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return Container(
                          child: new Wrap(
                            children: <Widget>[
                              new ListTile(
                                  leading: new Icon(Icons.edit),
                                  title: new Text('Edit subject'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditSubjectScreen(
                                                    widget.store,
                                                    widget.course,
                                                    widget.store.subject)));
                                  }),
                              new ListTile(
                                leading: new Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                title: new Text(
                                  'Delete subject',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: Text('Confirm'),
                                            content: Text(
                                                'Do you really want to delete '
                                                'subject ${widget.store.subject.name} and all '
                                                'its notes and questions?'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('Yes'),
                                                textColor: Colors.red,
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await widget.store
                                                      .deleteSubject(
                                                          widget
                                                              .store.subject.id,
                                                          widget.course.id);
                                                  Navigator.pop(context);
                                                  widget.store.loadSubjects(
                                                      widget.course.id);
                                                },
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('No'),
                                              ),
                                            ],
                                          ));
                                },
                              ),
                            ],
                          ),
                        );
                      });
                },
              )*/
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: kPrimaryColor,
            child: Icon(Icons.add,color: Colors.black,),
            onPressed: () {
              if (currentTab == kTabNotes) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NoteEdit(widget.store, null)));
              }
              if (currentTab == kTabQuestions) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuestionEdit(widget.store,
                            widget.course, widget.store.subject, null)));
              }
            },
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              NoteList(widget.store, widget.course, widget.store.subject,
                  currentMode, (mode, i) {
                setState(() {
                  print("change mode $mode");
                  currentMode = mode;
                  currentIndex = i;
                });
              }, currentIndex),
              QuestionList(widget.store, widget.course, widget.store.subject,
                  currentMode, (mode, i){
                    setState(() {
                      print("change mode $mode");
                      currentMode = mode;
                      currentIndex = i;
                    });
                  },currentIndex),
              // Text('Mind map'),
            ],
          ),
          /* bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: Icon(
                      LineAwesomeIcons.bars,
                      color: Colors.white
                          .withAlpha(currentMode == kModeList ? 255 : 100),
                    ),
                    onPressed: () {
                      print("list");
                      setState(() {
                        currentMode = kModeList;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Icon(
                      LineAwesomeIcons.copy,
                      color: Colors.white
                          .withAlpha(currentMode == kModeCarousel ? 255 : 100),
                    ),
                    onPressed: () {
                      print("carousel");
                      setState(() {
                        currentMode = kModeCarousel;
                      });
                    },
                  ),
                ),
              ],
            ),
            shape: CircularNotchedRectangle(),
            color: kDarkGrey,
            elevation: 10,
          ),*/
        );
      });
}
