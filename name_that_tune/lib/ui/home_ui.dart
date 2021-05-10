import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';
import 'package:bordered_text/bordered_text.dart';

class HomeUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    var mode;

    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) => controller?.firestoreUser?.value?.uid == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //     begin: Alignment.topRight,
                  //     end: Alignment.bottomLeft,
                  //     colors: [
                  //   Colors.pink,
                  //   Colors.cyan,
                  //   Colors.lime,
                  //   Colors.amber,
                  //   Colors.red
                  // ])),
                  gradient: RadialGradient(radius: 1, stops: [
                //0.1,
                0.4,
                0.6,
                1.0
              ], colors: [
                //Colors.cyan.shade50,
                Colors.cyan.shade100,
                Colors.cyan.shade200,
                Colors.lightBlue
              ])),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  actions: [
                    IconButton(
                        icon: Icon(Icons.settings),
                        color: Colors.pink.shade300,
                        onPressed: () {
                          Get.to(SettingsUI());
                        }),
                  ],
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 60),
                        child: Text(
                            'Name That Tune, ' +
                                controller.firestoreUser.value.name
                                    .split(' ')[0] +
                                '!',
                            textScaleFactor: 5,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Image.network(
                          //     'https://steamuserimages-a.akamaihd.net/ugc/844839873131070481/AB66503A189DA5B9547557C82E13CB5E6061EEC1/'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(100, 50),
                                      primary: Colors.pink.shade300),
                                  child: Text(
                                    'Game Mode',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  onPressed: () async {
                                    mode = "game";
                                    Get.to(PlaylistUI(), arguments: mode);
                                  }),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(100, 50),
                                      primary: Colors.pink.shade300),
                                  child: Text(
                                    'Dance Mode',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  onPressed: () async {
                                    mode = "dance";
                                    Get.to(PlaylistUI(), arguments: mode);
                                  }),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )),
    );
  }
}
