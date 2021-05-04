import 'package:flutter/material.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

class GameRecapUI extends StatefulWidget {
  @override
  _GameRecapState createState() => _GameRecapState();
}

class _GameRecapState extends State<GameRecapUI> {
  var data = Get.arguments;
  String playlistName;
  int finalScore;
  List<String> responses = [
    "Way to go",
    "Congratulations",
    "Great job",
    "You did it",
    "Nice guessing",
    "You Named Those Tunes",
    "What a game",
    "Good going",
    "Fantastic",
    "Amazing"
  ];

  @override
  void initState() {
    super.initState();
    playlistName = data[0];
    finalScore = data[1];
    responses.shuffle();
  }

  Color getColor(Set<MaterialState> states) {
    return Colors.amber.shade700;
  }

  Size getButtonSize(Set<MaterialState> states) {
    return Size(200, 70);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
        init: AuthController(),
        builder: (controller) => controller?.firestoreUser?.value?.uid == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black12, //Colors.amber.shade700,
                  title: Text("Game Recap"),
                  actions: <Widget>[],
                ),
                backgroundColor: Colors.black,
                body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 60),
                          child: Text(
                              responses.first +
                                  ", " +
                                  controller.firestoreUser.value.name
                                      .split(' ')[0] +
                                  "!",
                              textScaleFactor: 4,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.fromLTRB(48, 0, 48, 0),
                              child: ElevatedButton(
                                  child: Text("Play Again"),
                                  onPressed: () async {
                                    Get.to(SongUI(), arguments: playlistName);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            getColor),
                                    minimumSize:
                                        MaterialStateProperty.resolveWith(
                                            getButtonSize),
                                  )),
                            )),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.fromLTRB(48, 0, 48, 0),
                              child: ElevatedButton(
                                  child: Text("Home"),
                                  onPressed: () async {
                                    Get.offAll(HomeUI());
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            getColor),
                                    minimumSize:
                                        MaterialStateProperty.resolveWith(
                                            getButtonSize),
                                  )),
                            )),
                          ],
                        )
                      ]),
                )));
  }
}
