import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

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
          : Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black12, //Colors.amber.shade700,
                // title: // Text("Welcome, " + controller.firestoreUser.value.name.split(' ')[0]),
                actions: [
                  IconButton(
                      icon: Icon(Icons.settings),
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
                          textScaleFactor: 4,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
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
                                    primary: Colors.amber.shade700),
                                child: Text('Game Mode'),
                                onPressed: () async {
                                  mode = "game";
                                  Get.to(PlaylistUI(), arguments: mode);
                                }),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.amber.shade700),
                                child: Text('Dance Mode'),
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
            ),
    );
  }
}
