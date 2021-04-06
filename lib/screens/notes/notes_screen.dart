import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:studio/utils/Utils.dart';

import '../../constants.dart';
import '../../courses_store.dart';
import '../../models/course.dart';
import '../../models/note.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import '../questions/edit_question_screen.dart';
import 'edit_note_screen.dart';

class NoteList extends StatefulWidget {
  final CoursesStore store;
  final Course course;
  final Subject subject;
  final int mode;
  final Function changeMode;
  final int index;

  NoteList(this.store, this.course, this.subject, this.mode, this.changeMode,
      this.index);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> with TickerProviderStateMixin {
  int editState = -1;
  bool bookmarked = false;
  CarouselController carouselController = CarouselController();

  @override
  void initState() {
    print("init state notes");
    widget.store.loadNotes(widget.subject.id);
    super.initState();
  }

  Widget getTrailingIcon(int index) {
    int opacity = 0;
    if (editState == index) opacity = 255;

    if (editState != index) return null;

    return IconButton(
      icon: Icon(
        LineAwesomeIcons.trash,
      ),
      color: Colors.red.withAlpha(opacity),
      onPressed: () {
        //widget.store.deleteNote(widget.store.notes.elementAt(index).id);
      },
    );
  }

  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
        print("build notes view");
        return ModalProgressHUD(
          color: kLightGrey,
          child: resultWidget(context, widget.store.notes),
          inAsyncCall: widget.store.isNotesLoading,
        );
      });

  resultWidget(BuildContext context, List<Note> items) {
    if (!widget.store.isNotesLoading && items.length == 0) {
      return EmptyNotesScreen(bookmarked, (state) {
        widget.store.filterNotes(state);
        setState(() {
          bookmarked = state;
        });
      });
    }

    var list = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length + 1,
        itemBuilder: (_, index) {
          if (index == 0) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 4),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    /*Switch(
                      activeColor: kPrimaryColor,
                      value: bookmarked,
                      onChanged: (state) {
                        widget.store.filterNotes(state);
                        setState(() {
                          bookmarked = state;
                        });
                      },
                    ),
                    Text('Bookmarked')*/
                  ],
                ),
              ),
            );
          }

          final item = items[index - 1];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius:
                              20.0, // has the effect of softening the shadow
                          spreadRadius:
                              10.0, // has the effect of extending the shadow
                          offset: Offset(
                            0.0, // horizontal, move right 10
                            0.0, // vertical, move down 10
                          ),
                        )
                      ]),
                  child: ListTile(
                      onTap: () {
                        setState(() {
                          editState = -1;
                          //currentIndex = index;
                          widget.changeMode(kModeCarousel, index);
                        });
                      },
                      onLongPress: () {
                        /*setState(() {
                        editState = index;
                      });*/

                        var text = item.text;
                        if (item.text.length > 100)
                          text = item.text.substring(0, 100) + '...';

                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  //title: Text('Confirm'),
                                  content: Text(text),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Delete'),
                                      textColor: Colors.red,
                                      onPressed: () {
                                        Navigator.pop(context);
                                        widget.store.deleteNote(item.id, () {
                                          widget.store
                                              .loadNotes(widget.subject.id);
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        print("note level: ${item.level}");
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => NoteEdit(
                                                    widget.store, item)));
                                      },
                                      child: Text('Edit'),
                                    ),
                                  ],
                                ));
                      },
                      //contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      title: Container(
                        child: Text(
                          item.text,
                          style: TextStyle(
                              color: kTitleColor,
                              fontSize: 18,
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      trailing: bookmarkButtonlist(item)
                      // getTrailingIcon(index),
                      ),
                ),
                Divider(
                  height: 1.5,
                )
              ],
            ),
          );
        });

    var carousel = getCarousel(items);

    if (widget.mode == kModeCarousel) return carousel;
    return list;
  }

  Timer timer1;
  Timer timer2;
  double currentIndexPage = 0;

  Widget getCarousel(List<Note> items) {
    var subjIndex = widget.store.subjects.indexOf(widget.subject);
    var count = items.length + 2;
    bool isLast = subjIndex == widget.store.notes.length;
    if (isLast) count--;

    return Column(
      children: [
        SizedBox(
          height: 5,
        ),
        CarouselSlider.builder(
          options: CarouselOptions(
              height: MediaQuery.of(context).size.height - 300,
              enableInfiniteScroll: false,
              initialPage: widget.index,

              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.height,

              onPageChanged: (int index, CarouselPageChangedReason reason) {
                setState(() {
                  currentIndexPage = index.toDouble();
                });
                print(index.toDouble());
              }),
          itemCount: count,
          carouselController: carouselController,
          itemBuilder: (ctx, i) {
            if (i == 0) {
              return coverSlider([
                Text(
                  widget.store.subjects[subjIndex].name,
                  style: TextStyle(fontSize: 28, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                /*Text(
                  widget.subject.bookTitle,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                )*/
              ]);
            }

            if (!isLast && i == count - 1) {
              return coverSlider([
                Text(
                  widget.store.subjects[subjIndex].name,
                  style: TextStyle(fontSize: 28, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                /*Text(
                  widget.subject.bookTitle,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),*/
                SizedBox(
                  height: 30,
                ),
                IconButton(
                  icon: Icon(
                    LineAwesomeIcons.chevron_right,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    print("load ${widget.store.subjects[subjIndex].name}");
                    widget.store.setSubject(widget.store.subjects[subjIndex]);
                    widget.store.loadNotes(widget.store.subjects[subjIndex].id);
                    carouselController.jumpToPage(0);
                    //widget.store.loadNotes(widget.store.subjects[subjIndex + 1].id);
                  },
                )
              ]);
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(40),
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          items[i - 1].text,
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Quicksand",
                              color: HexColor("#5D646B"),
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 0, left: 15, child: bookmarkButton(items[i - 1])),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 20),
        DotsIndicator(
          dotsCount: count,
          position: currentIndexPage.toDouble(),
          decorator: DotsDecorator(
              activeSize: Size(12, 12),
              activeColor: Colors.grey[500],
              color: Colors.grey[300],
              spacing: EdgeInsets.all(1.5),
              size: Size(5, 5)),
        )
      ],
    );
  }

  Widget coverSlider(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Container(
        padding: EdgeInsets.all(40),
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 15.0),
        decoration: BoxDecoration(
          color: kPrimaryColor,
        ),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: children),
        ),
      ),
    );
  }

  Widget bookmarkButton(Note item) {
    Color color = item.bookmark ? kAccentColor : Colors.grey;
    return IconButton(
      icon: Icon(
        Icons.info_outline,
        color: color,
        size: 20,
      ),
      onPressed: () {
        setState(() {
          item.bookmark = !item.bookmark;
          widget.store.bookmarkNote(item.id, item.bookmark);
        });
      },
    );
  }

  Widget attentionButton(Note item) {
    Color color = item.attention ? Colors.red : Colors.grey.withAlpha(160);
    return IconButton(
      icon: Icon(
        LineAwesomeIcons.exclamation_triangle,
        size: 30,
        color: color,
      ),
      onPressed: () {
        setState(() {
          item.attention = !item.attention;
          widget.store.attentionNote(item.id, item.attention);
        });
      },
    );
  }

  bookmarkButtonlist(Note item) {
    Color color = item.bookmark ? kAccentColor : Colors.transparent;
    return IconButton(
      icon: Icon(
        Icons.info_outline,
        color: color,
        size: 20,
      ),
      onPressed: () {
        /*  setState(() {
          item.bookmark = !item.bookmark;
          widget.store.bookmarkQuestion(item.id, item.bookmark);
        });*/
      },
    );
  }
}

class EmptyNotesScreen extends StatelessWidget {
  final bool bookmarked;
  final Function onFilter;

  EmptyNotesScreen(this.bookmarked, this.onFilter);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                //color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[],
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              bookmarked ? 'No bookmarked notes yet' : 'No notes yet',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
