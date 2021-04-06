import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

enum ButtonStatus { correct, incorrect, nil }

class SongUI extends StatefulWidget {
  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongUI> {
  var data = Get.arguments;
  int round = 0;
  String correctAnswer = "";
  int score = 0;
  PlaylistModel _playlist;
  Future<dynamic> _playlistFuture;
  List<dynamic> _images;
  Future<dynamic> _imagesFuture;
  List<String> _answerChoices;
  Future<dynamic> _answersFuture;
  YoutubePlayerController _controller;
  ButtonStatus buttonOne = ButtonStatus.nil;
  ButtonStatus buttonTwo = ButtonStatus.nil;
  ButtonStatus buttonThree = ButtonStatus.nil;
  ButtonStatus buttonFour = ButtonStatus.nil;

  @override
  void initState() {
    super.initState();
    print(Get.arguments);
    _playlistFuture = initializePlaylist();
    _imagesFuture = getImages('init');
    _answersFuture = getAnswers('init');
  }

  Future initializePlaylist() async {
    return await convertPlaylistToUsable(data).then((playlist) {
      _playlist = playlist;
      _controller = YoutubePlayerController(
        initialVideoId: '',
        params: YoutubePlayerParams(
          playlist: _playlist.songs,
          showControls: true,
          showFullscreenButton: true,
          autoPlay: true,
        ),
      );
      return playlist;
    }).onError((error, stackTrace) {
      print(error);
      return error;
    });
  }

  Future getImages(String method) async {
    if (method == 'init') {
      dynamic pl = await initializePlaylist();
    }
    // eventually use playlist and song to plug in the year
    return yearToImages(1967).then((images) {
      _images = images[0];
      _images.shuffle();
      return images;
    }).onError((error, stackTrace) {
      print(error);
      return error;
    });
  }

  Future getAnswers(String method) async {
    if (method == 'init') {
      dynamic pl = await initializePlaylist();
    }
    return createAnswerChoicesFromPlaylist(
            _playlist.songs[round], _playlist.name)
        .then((answers) {
      _answerChoices = answers;
      correctAnswer = _answerChoices[0];
      _answerChoices.shuffle();
      return answers;
    }).onError((error, stackTrace) {
      print(error);
      return error;
    });
  }

  void progressRound() {
    round++;
    buttonOne = ButtonStatus.nil;
    buttonTwo = ButtonStatus.nil;
    buttonThree = ButtonStatus.nil;
    buttonFour = ButtonStatus.nil;
    // other stuff
    if (round <= 4) {
      _controller.nextVideo();
      setState(() {
        _imagesFuture = getImages('update');
        _answersFuture = getAnswers('update');
      });
    } else {
      Get.to(GameRecapUI());
    }
  }

  Color getColorOne(Set<MaterialState> states) {
    if (buttonOne == ButtonStatus.correct) {
      return Colors.green;
    } else if (buttonOne == ButtonStatus.incorrect) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  Color getColorTwo(Set<MaterialState> states) {
    if (buttonTwo == ButtonStatus.correct) {
      return Colors.green;
    } else if (buttonTwo == ButtonStatus.incorrect) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  Color getColorThree(Set<MaterialState> states) {
    if (buttonThree == ButtonStatus.correct) {
      return Colors.green;
    } else if (buttonThree == ButtonStatus.incorrect) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  Color getColorFour(Set<MaterialState> states) {
    if (buttonFour == ButtonStatus.correct) {
      return Colors.green;
    } else if (buttonFour == ButtonStatus.incorrect) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ListView(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            PrimaryButton(
                labelText: "Play",
                onPressed: () async {
                  _controller.play();
                }),
            PrimaryButton(
                labelText: "Pause",
                onPressed: () async {
                  _controller.pause();
                }),
          ],
        ),
        PrimaryButton(
            labelText: "Skip song",
            onPressed: () async {
              // _controller.nextVideo();
              progressRound();
            }),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 300,
              child: Stack(
                children: [
                  Center(
                    child: FutureBuilder(
                      future: _playlistFuture,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          return Container(
                              height: 1 /* change back to 0 */,
                              width: 1 /* change back to 0 */,
                              child: YoutubePlayerIFrame(
                                controller: _controller,
                                aspectRatio: 16 / 9,
                              ));
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                  Center(
                    child: FutureBuilder(
                      future: _imagesFuture,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          return Image.network(_images[0]);
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: FutureBuilder(
              future: _answersFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasData) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              labelText: _answerChoices[0],
                              onPressed: () async {
                                if (_answerChoices[0] == correctAnswer) {
                                  score++;
                                  buttonOne = ButtonStatus.correct;
                                  await Future.delayed(Duration(seconds: 3));
                                  progressRound();
                                } else {
                                  buttonOne = ButtonStatus.incorrect;
                                }
                              },
                              color: MaterialStateProperty.resolveWith(
                                  getColorOne),
                            ),
                          ),
                          Expanded(
                            child: PrimaryButton(
                              labelText: _answerChoices[1],
                              onPressed: () async {
                                if (_answerChoices[1] == correctAnswer) {
                                  score++;
                                  buttonTwo = ButtonStatus.correct;
                                  await Future.delayed(Duration(seconds: 3));
                                  progressRound();
                                } else {
                                  buttonTwo = ButtonStatus.incorrect;
                                }
                              },
                              color: MaterialStateProperty.resolveWith(
                                  getColorTwo),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              labelText: _answerChoices[2],
                              onPressed: () async {
                                if (_answerChoices[2] == correctAnswer) {
                                  score++;
                                  buttonThree = ButtonStatus.correct;
                                  await Future.delayed(Duration(seconds: 3));
                                  progressRound();
                                } else {
                                  buttonThree = ButtonStatus.incorrect;
                                }
                              },
                              color: MaterialStateProperty.resolveWith(
                                  getColorThree),
                            ),
                          ),
                          Expanded(
                            child: PrimaryButton(
                              labelText: _answerChoices[3],
                              onPressed: () async {
                                if (_answerChoices[3] == correctAnswer) {
                                  score++;
                                  buttonFour = ButtonStatus.correct;
                                  await Future.delayed(Duration(seconds: 3));
                                  progressRound();
                                } else {
                                  buttonFour = ButtonStatus.incorrect;
                                }
                              },
                              color: MaterialStateProperty.resolveWith(
                                  getColorFour),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              }),
        )
      ],
    )));
  }
}
