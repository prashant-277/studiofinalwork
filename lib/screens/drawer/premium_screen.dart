import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studio/courses_store.dart';
import 'package:studio/widgets/drawer.dart';

import '../../constants.dart';

class premium_screen extends StatefulWidget {
  CoursesStore store;

  premium_screen(this.store);

  @override
  _premium_screenState createState() => _premium_screenState();
}

class _premium_screenState extends State<premium_screen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      /* AppBar(
        backgroundColor: HexColor("8BD4A1"),
        elevation: 0,
        centerTitle: true,
        title: Container(
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Unlock the full \nexperience",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: kContrastColor,
                fontSize: 20,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w200),
          ),
        ),
      )*/
      drawer: MainDrawer(widget.store),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Image.asset("assets/images/purchase.png"),
              Stack(
                children: [
                  Image.asset("assets/images/123123123.png"),
                  Container(
                    margin: EdgeInsets.only(top: 36),
                    child: IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        print("your menu action here");
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 46),
                    child: Center(
                      child: Text(
                        "Unlock the full \nexperience",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: kContrastColor,
                            fontSize: 22.5,
                            fontFamily: "Quicksand",
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                  margin: EdgeInsets.all(0),
                  elevation: 0,
                  child: Container(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            "assets/images/Banner2x.png",
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Container(
                              alignment: Alignment.topCenter,
                              /*child: Text(
                                "Unlock the full \nexperience",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kContrastColor,
                                    fontSize: 23,
                                    fontFamily: "Quicksand",
                                    fontWeight: FontWeight.w200),
                              ),*/
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 4),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 3.0,
                      height: 15,
                      color: Color(0xffff8d2b),
                      child: Center(
                        child: Text(
                          "MOST POPULAR",
                          style: TextStyle(
                              color: kContrastColor,
                              fontSize: 10,
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.w200),
                        ),
                      ),
                    ),
                    //ANNUAL
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffff8d2b), width: 1),
                          borderRadius: BorderRadius.circular(3),
                          color: Color(0xffE1E1E1)),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FlatButton(
                            height: 60,
                            color: Color(0xff3BB382),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ANNUAL",
                                  style: TextStyle(
                                      color: kContrastColor,
                                      fontSize: 16,
                                      fontFamily: "Quicksand",
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "€ 7.99/MONTH*",
                                  style: TextStyle(
                                      color: kContrastColor,
                                      fontSize: 16,
                                      fontFamily: "Quicksand",
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
              ),

              //monthly
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Color(0xffE1E1E1)),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "MONTHLY",
                              style: TextStyle(
                                  color: Color(0xFF5A5A5A),
                                  fontSize: 16,
                                  fontFamily: "Quicksand",
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "€ 15.49/MONTH",
                              style: TextStyle(
                                  color: Color(0xFF5A5A5A),
                                  fontSize: 16,
                                  fontFamily: "Quicksand",
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              //billed as one payment
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 20, right: 20),
                child: Text(
                  "* Billed as one payment",
                  style: TextStyle(
                      color: Color(0xFF5A5A5A),
                      fontSize: 14,
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
