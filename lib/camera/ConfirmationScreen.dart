import 'dart:io';

import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {

  final String file;

  ConfirmationScreen(this.file);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: Center(
              child: Image.file(File(file)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 120,
              padding: EdgeInsets.all(20.0),
              color: Color.fromRGBO(0, 0, 0, .3),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ButtonTheme(
                        height: 70,
                        child: RaisedButton(
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.transparent)),
                          onPressed: (){
                            Navigator.of(context).pop(false);
                          },
                          color: Colors.transparent,
                          textColor: Colors.white,
                          elevation: 0,
                          child: Icon(Icons.close, size: 60,),
                        ),
                      ),
                      ButtonTheme(
                        height: 70,
                        child: RaisedButton(
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.transparent)),
                          onPressed: (){
                            Navigator.of(context).pop(true);
                          },
                          color: Colors.transparent,
                          textColor: Colors.white,
                          elevation: 0,
                          child: Icon(Icons.check, size: 60,),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
