import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

enum ButtonStatus { correct, incorrect, nil }

class SongUI extends StatefulWidget {
  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongUI> {
  var rounds = [];
  String user = "";
  int guesses = 0;
  Stopwatch s = new Stopwatch();
  var songs = [];
  var gameid = "";
  DateTime date = new DateTime.now();

  var data = Get.arguments;
  int round = 0;
  String correctAnswer = "";
  var scores = [];
  PlaylistModel _playlist;
  Future<dynamic> _playlistFuture;
  dynamic _image;
  Future<dynamic> _imagesFuture;
  List<String> _answerChoices;
  Future<dynamic> _answersFuture;
  YoutubePlayerController _controller;
  final correctPlayer = AudioPlayer();
  final incorrectPlayer = AudioPlayer();
  var correctSound;
  var incorrectSound;
  final FirebaseAuth auth = FirebaseAuth.instance;

  ButtonStatus buttonOne = ButtonStatus.nil;
  ButtonStatus buttonTwo = ButtonStatus.nil;
  ButtonStatus buttonThree = ButtonStatus.nil;
  ButtonStatus buttonFour = ButtonStatus.nil;
  bool buttonOneActive = true;
  bool buttonTwoActive = true;
  bool buttonThreeActive = true;
  bool buttonFourActive = true;

  @override
  void initState() {
    super.initState();
    _playlistFuture = initializePlaylist();
    _imagesFuture = getImages('init');
    _answersFuture = getAnswers('init');
    initializeAudio();
    final User u = auth.currentUser;
    user = u.email.toString();
  }

  Future initializeAudio() async {
    correctSound =
        await correctPlayer.setAsset('476178__unadamlar__correct-choice.wav');
    /* incorrectSound = await incorrectPlayer
        .setAsset('181858__timgormly__training-program-incorrect1.aiff'); */
  }

  Future initializePlaylist() async {
    return await convertPlaylistToUsable(data).then((playlist) {
      _playlist = playlist;
      _playlist.songs.shuffle();
      songs = _playlist.songs;
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
    return videoIDToImage(songs[round]).then((image) {
      _image = image;
      return image;
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
    // reset and update
    if (round <= 4) {
      _controller.nextVideo();
      s.reset();
      buttonOne = ButtonStatus.nil;
      buttonTwo = ButtonStatus.nil;
      buttonThree = ButtonStatus.nil;
      buttonFour = ButtonStatus.nil;
      setAllButtonActivity(true);
      s.start();
      setState(() {
        _imagesFuture = getImages('update');
        _answersFuture = getAnswers('update');
      });
    } else {
      Get.to(GameRecapUI());
    }
  }

  void setAllButtonActivity(bool active) {
    setState(() {
      buttonOneActive = active;
      buttonTwoActive = active;
      buttonThreeActive = active;
      buttonFourActive = active;
    });
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
                          return Image.network(_image);
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
                              onPressed: buttonOneActive
                                  ? () async {
                                      guesses++;
                                      if (_answerChoices[0] == correctAnswer) {
                                        s.stop();
                                        correctPlayer.play();
                                        var time = s.elapsedMilliseconds;
                                        buttonOne = ButtonStatus.correct;
                                        setAllButtonActivity(false);
                                        await Future.delayed(
                                            Duration(seconds: 3));
                                        addRound(guesses, user, time / 1000,
                                                songs[round])
                                            .then((value) {
                                          rounds.add(value);
                                          switch (guesses) {
                                            case 1:
                                              {
                                                scores.add(100);
                                              }
                                              break;
                                            case 2:
                                              {
                                                scores.add(75);
                                              }
                                              break;
                                            case 3:
                                              {
                                                scores.add(50);
                                              }
                                              break;
                                            case 4:
                                              {
                                                scores.add(25);
                                              }
                                              break;
                                          }
                                          guesses = 0;
                                          if (round > 4) {
                                            addGame(rounds, user).then((value) {
                                              addScore(
                                                  value,
                                                  user,
                                                  date,
                                                  scores
                                                      .reduce((a, b) => a + b));
                                            });
                                          }
                                        });
                                        await correctPlayer.stop();
                                        progressRound();
                                      } else {
                                        buttonOne = ButtonStatus.incorrect;
                                        setState(() => buttonOneActive = false);
                                      }
                                    }
                                  : () async {},
                              color: MaterialStateProperty.resolveWith(
                                  getColorOne),
                            ),
                          ),
                          Expanded(
                            child: PrimaryButton(
                              labelText: _answerChoices[1],
                              onPressed: buttonTwoActive
                                  ? () async {
                                      guesses++;
                                      if (_answerChoices[1] == correctAnswer) {
                                        s.stop();
                                        correctPlayer.play();
                                        var time = s.elapsedMilliseconds;
                                        buttonTwo = ButtonStatus.correct;
                                        setAllButtonActivity(false);
                                        await Future.delayed(
                                            Duration(seconds: 3));
                                        addRound(guesses, user, time / 1000,
                                                songs[round])
                                            .then((value) {
                                          rounds.add(value);
                                          switch (guesses) {
                                            case 1:
                                              {
                                                scores.add(100);
                                              }
                                              break;
                                            case 2:
                                              {
                                                scores.add(75);
                                              }
                                              break;
                                            case 3:
                                              {
                                                scores.add(50);
                                              }
                                              break;
                                            case 4:
                                              {
                                                scores.add(25);
                                              }
                                              break;
                                          }
                                          guesses = 0;
                                          if (round > 4) {
                                            addGame(rounds, user).then((value) {
                                              addScore(
                                                  value,
                                                  user,
                                                  date,
                                                  scores
                                                      .reduce((a, b) => a + b));
                                            });
                                          }
                                        });
                                        await correctPlayer.stop();
                                        progressRound();
                                      } else {
                                        buttonTwo = ButtonStatus.incorrect;
                                        setState(() => buttonTwoActive = false);
                                      }
                                    }
                                  : () async {},
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
                              onPressed: buttonThreeActive
                                  ? () async {
                                      guesses++;
                                      if (_answerChoices[2] == correctAnswer) {
                                        s.stop();
                                        correctPlayer.play();
                                        var time = s.elapsedMilliseconds;
                                        buttonThree = ButtonStatus.correct;
                                        setAllButtonActivity(false);
                                        await Future.delayed(
                                            Duration(seconds: 3));
                                        addRound(guesses, user, time / 1000,
                                                songs[round])
                                            .then((value) {
                                          rounds.add(value);
                                          switch (guesses) {
                                            case 1:
                                              {
                                                scores.add(100);
                                              }
                                              break;
                                            case 2:
                                              {
                                                scores.add(75);
                                              }
                                              break;
                                            case 3:
                                              {
                                                scores.add(50);
                                              }
                                              break;
                                            case 4:
                                              {
                                                scores.add(25);
                                              }
                                              break;
                                          }
                                          guesses = 0;
                                          if (round > 4) {
                                            addGame(rounds, user).then((value) {
                                              addScore(
                                                  value,
                                                  user,
                                                  date,
                                                  scores
                                                      .reduce((a, b) => a + b));
                                            });
                                          }
                                        });
                                        await correctPlayer.stop();
                                        progressRound();
                                      } else {
                                        buttonThree = ButtonStatus.incorrect;
                                        setState(
                                            () => buttonThreeActive = false);
                                      }
                                    }
                                  : () async {},
                              color: MaterialStateProperty.resolveWith(
                                  getColorThree),
                            ),
                          ),
                          Expanded(
                            child: PrimaryButton(
                              labelText: _answerChoices[3],
                              onPressed: buttonFourActive
                                  ? () async {
                                      guesses++;
                                      if (_answerChoices[3] == correctAnswer) {
                                        s.stop();
                                        correctPlayer.play();
                                        var time = s.elapsedMilliseconds;
                                        buttonFour = ButtonStatus.correct;
                                        setAllButtonActivity(false);
                                        await Future.delayed(
                                            Duration(seconds: 3));
                                        addRound(guesses, user, time / 1000,
                                                songs[round])
                                            .then((value) {
                                          rounds.add(value);
                                          switch (guesses) {
                                            case 1:
                                              {
                                                scores.add(100);
                                              }
                                              break;
                                            case 2:
                                              {
                                                scores.add(75);
                                              }
                                              break;
                                            case 3:
                                              {
                                                scores.add(50);
                                              }
                                              break;
                                            case 4:
                                              {
                                                scores.add(25);
                                              }
                                              break;
                                          }
                                          guesses = 0;
                                          if (round > 4) {
                                            addGame(rounds, user).then((value) {
                                              addScore(
                                                  value,
                                                  user,
                                                  date,
                                                  scores
                                                      .reduce((a, b) => a + b));
                                            });
                                          }
                                        });
                                        await correctPlayer.stop();
                                        progressRound();
                                      } else {
                                        buttonFour = ButtonStatus.incorrect;
                                        setState(
                                            () => buttonFourActive = false);
                                      }
                                    }
                                  : () async {},
                              color: MaterialStateProperty.resolveWith(
                                  getColorFour),
                            ),
                          ),
                        ],
                      )
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
