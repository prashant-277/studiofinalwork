import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:drag_list/drag_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:studio/utils/Utils.dart';

import '../../constants.dart';
import '../../courses_store.dart';
import '../../models/course.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import 'edit_question_screen.dart';

class QuestionList extends StatefulWidget {
  final CoursesStore store;
  final Course course;
  final Subject subject;
  final int mode;
  final Function changeMode;
  final int index;

  QuestionList(this.store, this.course, this.subject, this.mode,
      this.changeMode, this.index);

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  int editState = -1;
  bool bookmarked = false;
  CarouselController carouselController = CarouselController();
  final controller = PageController(viewportFraction: 0.8);

  bool textvisible = false;

  @override
  void initState() {
    widget.store.loadQuestions(subjectId: widget.store.subject.id);
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
        //widget.store.deleteQuestion(widget.store.questions.elementAt(index).id);
      },
    );
  }

  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
        return ModalProgressHUD(
          color: kLightGrey,
          child: resultWidget(context, widget.store.questions),
          inAsyncCall: widget.store.isQuestionsLoading,
        );
      });

  resultWidget(BuildContext context, List<Question> items) {
    if (!widget.store.isQuestionsLoading && items.length == 0) {
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: bookmarkToggle()),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                bookmarked ? 'No bookmarked questions yet' : 'No questions yet',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }

    var dragList = DragList<Question>(
      items: items,
      itemExtent: 80,
      handleBuilder: (context) {
        return Container(
          height: 72.0,
          child: Icon(LineAwesomeIcons.bars),
        );
      },
      itemBuilder: (context, item, handle) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Container(
            //padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20.0, // has the effect of softening the shadow
                    spreadRadius:
                        10.0, // has the effect of extending the shadow
                    offset: Offset(
                      0.0, // horizontal, move right 10
                      0.0, // vertical, move down 10
                    ),
                  )
                ]),
            child: ListTile(
              onTap: () {},
              title: Container(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: handle,
                    ),
                    Text(
                      item.value.text
                              .substring(0, min(item.value.text.length, 30)) +
                          (item.value.text.length > 30 ? '...' : ''),
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    var list = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length + 1,
        itemBuilder: (_, index) {
          if (index == 0) {
            return bookmarkToggle();
          }

          final item = items[index - 1];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      /*boxShadow: [
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
                      ]*/),
                  child: ListTile(
                      onTap: () {
                        setState(() {
                          editState = -1;
                          widget.changeMode(kModeCarousel, index);
                          currentIndexPage = index.toDouble();
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
                                        widget.store.deleteQuestion(item.id, () {
                                          widget.store.loadQuestions(
                                              subjectId: widget.subject.id);
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    QuestionEdit(
                                                        widget.store,
                                                        widget.course,
                                                        widget.subject,
                                                        item)));
                                      },
                                      child: Text('Edit'),
                                    ),
                                  ],
                                ));
                      },
                      //contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      title: Container(
                        child: Text(capitalize(item.text),
                          style: TextStyle(
                              color: kTitleColor,
                              fontSize: 18,
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      trailing: bookmarkButtonlist(item)

                      //getTrailingIcon(item),
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

  double currentIndexPage = 0;

  Widget getCarousel(List<Question> items) {
    var subjIndex = widget.store.subjects.indexOf(widget.subject);
    var count = items.length + 2;
    bool isLast = subjIndex == widget.store.questions.length;
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
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              enlargeCenterPage: true,
              onPageChanged: (int index, CarouselPageChangedReason reason) {
                setState(() {
                  currentIndexPage = index.toDouble();
                  textvisible = false;
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
                  style: TextStyle(
                      fontSize: 28,
                      fontFamily: "Quicksand",
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
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
                  style: TextStyle(
                      fontSize: 28,
                      fontFamily: "Quicksand",
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                /*Text(
                  widget.subject.bookTitle,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),*/
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Next subject",
                  style: TextStyle(
                      fontSize: 28,
                      fontFamily: "Quicksand",
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: Icon(
                    LineAwesomeIcons.chevron_right,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    /*print("load ${widget.store.subjects[subjIndex].name}");
                    widget.store.setSubject(widget.store.subjects[subjIndex]);
                    widget.store.loadQuestions(
                        subjectId: widget.store.subjects[subjIndex].id);
                    carouselController.jumpToPage(0);
*/
                    print("load ${widget.store.subjects[subjIndex + 1].name}" +
                        "000000000000");
                    widget.store
                        .setSubject(widget.store.subjects[subjIndex + 1]);
                    widget.store.loadQuestions(
                        subjectId: widget.store.subjects[subjIndex + 1].id);
                    carouselController.jumpToPage(1);

                    //widget.store.loadQuestions(widget.store.subjects[subjIndex + 1].id);
                  },
                )
              ]);
            }
            if (isLast && i == count-1) {
              return coverSlider([
                Text(
                  "last page",
                  style: TextStyle(
                      fontSize: 28,
                      fontFamily: "Quicksand",
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                /*Text(
                  widget.subject.bookTitle,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),*/
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Back to subject list",
                  style: TextStyle(
                      fontSize: 28,
                      fontFamily: "Quicksand",
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: Icon(
                    LineAwesomeIcons.chevron_right,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    /*print("load ${widget.store.subjects[subjIndex].name}");
                    widget.store.setSubject(widget.store.subjects[subjIndex]);
                    widget.store.loadQuestions(
                        subjectId: widget.store.subjects[subjIndex].id);
                    carouselController.jumpToPage(0);
                    */
                    Navigator.pop(context);
                    //widget.store.loadQuestions(widget.store.subjects[subjIndex + 1].id);
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
                    width: MediaQuery.of(context).size.width / 1.5,
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(capitalize(items[i - 1].text),
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Quicksand",
                              color: kDarkBlue,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: textvisible == true ? 20 : 65),
                        InkWell(
                          onTap: () {
                            setState(() {
                              textvisible = true;
                            });
                          },
                          child: textvisible == true
                              ? Container()
                              : Image.asset(
                                  "assets/images/blurimage.png",
                                  height:
                                      MediaQuery.of(context).size.height / 8,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  fit: BoxFit.fill,
                                ),
                        ),
                        Visibility(
                          visible: textvisible,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                            child: Text(capitalize(items[i - 1].answer),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Quicksand",
                                  color: HexColor("#5D646B"),
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
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

  Widget bookmarkToggle() {
    return Container(
      //color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            /*Switch(
              activeColor: kPrimaryColor,
              value: bookmarked,
              onChanged: (state) {
                widget.store.filterQuestions(state);
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

  Widget bookmarkButton(Question item) {
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
          widget.store.bookmarkQuestion(item.id, item.bookmark);
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  bookmarkButtonlist(Question item) {
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
