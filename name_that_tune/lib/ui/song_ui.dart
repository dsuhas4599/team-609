import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

enum ButtonStatus { correct, incorrect, nil }
enum VideoStatus { playing, paused }

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
  Future<PlaylistModel> _playlistFuture;
  dynamic _image;
  Future<String> _imagesFuture;
  List<String> _answerChoices;
  Future<List<String>> _answersFuture;
  YoutubePlayerController _controller;
  final correctPlayer = audio.AudioPlayer();
  final incorrectPlayer = audio.AudioPlayer();
  var correctSound;
  var incorrectSound;
  final FirebaseAuth auth = FirebaseAuth.instance;

  VideoStatus ppButtonStatus = VideoStatus.playing;
  ButtonStatus buttonOne = ButtonStatus.nil;
  ButtonStatus buttonTwo = ButtonStatus.nil;
  ButtonStatus buttonThree = ButtonStatus.nil;
  ButtonStatus buttonFour = ButtonStatus.nil;
  bool buttonOneActive = true;
  bool buttonTwoActive = true;
  bool buttonThreeActive = true;
  bool buttonFourActive = true;
  bool skipActive = true;

  StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    _playlistFuture = initializePlaylist();
    initializeAudio();
    final User u = auth.currentUser;
    user = u.email.toString();
  }

  Future<void> initializeAudio() async {
    correctSound = await correctPlayer.setUrl(
        'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/476178__unadamlar__correct-choice.wav?alt=media&token=5414fc7b-edc2-4edd-b282-fcea34188c8e');
    incorrectSound = await incorrectPlayer.setUrl(
        'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/331912__kevinvg207__wrong-buzzer.wav?alt=media&token=c12f90d2-0922-49d5-95cf-9fa012817d2d');
    return;
  }

  Future<PlaylistModel> initializePlaylist() async {
    _playlist = await convertPlaylistToUsable(data);
    _playlist.songs.shuffle();
    _playlist.songs = _playlist.songs.sublist(0, 5);
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
    sub = _controller.listen((event) {
      print(event.playerState.toString());
      if (event.playerState == PlayerState.ended) {
        progressRound(false);
      }
    });
    setState(() {
      _imagesFuture = getImages();
      _answersFuture = getAnswers();
    });
    return _playlist;
  }

  Future<String> getImages() async {
    _image = await videoIDToImage(songs[round]);
    return _image;
  }

  Future<List<String>> getAnswers() async {
    _answerChoices =
        await createAnswerChoicesFromPlaylist(songs[round], _playlist.name);
    correctAnswer = _answerChoices[0];
    _answerChoices.shuffle();
    return _answerChoices;
  }

  void progressRound(bool skipVideo) {
    round++;
    // reset and update
    if (round <= 4) {
      setState(() {
        _imagesFuture = getImages();
        _answersFuture = getAnswers();
        ppButtonStatus = VideoStatus.playing;
      });
      if (skipVideo) {
        _controller.nextVideo();
      }
      s.reset();
      buttonOne = ButtonStatus.nil;
      buttonTwo = ButtonStatus.nil;
      buttonThree = ButtonStatus.nil;
      buttonFour = ButtonStatus.nil;
      setAllButtonActivity(true);
      s.start();
    } else {
      sub.cancel();
      int finalScore = scores.reduce((a, b) => a + b);
      Get.to(GameRecapUI(), arguments: [data, finalScore]);
    }
  }

  void setAllButtonActivity(bool active) {
    setState(() {
      buttonOneActive = active;
      buttonTwoActive = active;
      buttonThreeActive = active;
      buttonFourActive = active;
      skipActive = active;
    });
  }

  Color getColorOne(Set<MaterialState> states) {
    if (buttonOne == ButtonStatus.correct) {
      return Colors.lightGreenAccent.shade700;
    } else if (buttonOne == ButtonStatus.incorrect) {
      return Colors.grey.shade600;
    } else {
      return Colors.pink.shade300;
    }
  }

  Color getColorTwo(Set<MaterialState> states) {
    if (buttonTwo == ButtonStatus.correct) {
      return Colors.lightGreenAccent.shade700;
    } else if (buttonTwo == ButtonStatus.incorrect) {
      return Colors.grey.shade600;
    } else {
      return Colors.lightBlue;
    }
  }

  Color getColorThree(Set<MaterialState> states) {
    if (buttonThree == ButtonStatus.correct) {
      return Colors.lightGreenAccent.shade700;
    } else if (buttonThree == ButtonStatus.incorrect) {
      return Colors.grey.shade600;
    } else {
      return Colors.yellow;
    }
  }

  Color getColorFour(Set<MaterialState> states) {
    if (buttonFour == ButtonStatus.correct) {
      return Colors.lightGreenAccent.shade700;
    } else if (buttonFour == ButtonStatus.incorrect) {
      return Colors.grey.shade600;
    } else {
      return Colors.orange;
    }
  }

  Size buttonSizing(Set<MaterialState> states) {
    return Size(200, 125);
  }

  void scoring(int g) {
    switch (g) {
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
  }

  void feedback(int g) {
    switch (g) {
      case 1:
        {
          setState(() {
            _image =
                "https://media2.giphy.com/media/l3vRcttCynxJoxIrK/giphy.gif?cid=ecf05e47gdw3l5wic62gsdcvxv0ft94npf1lq0u0yf0jks8g&rid=giphy.gif&ct=g";
          });
        }
        break;
      case 2:
        {
          setState(() {
            _image =
                "https://media3.giphy.com/media/V72fyK86e9NQLOgtZi/giphy.gif?cid=ecf05e473mqydbqrztk2m45odvgyw03ld0ua24b9fwp52xay&rid=giphy.gif&ct=g";
          });
        }
        break;
      case 3:
        {
          setState(() {
            _image =
                "https://media1.giphy.com/media/lMBcCPM0VYfhh2zCAy/giphy.gif";
          });
        }
        break;
      case 4:
        {
          setState(() {
            _image =
                "https://media4.giphy.com/media/cOQSc9wAHifk1LlQBM/giphy.gif";
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // decoration: BoxDecoration(
        //     gradient: RadialGradient(
        //   radius: 1,
        //   stops: [0.2, 0.5], //[0.1, 0.4, 0.6, 1.0],
        //   colors: [
        //     //Colors.white,
        //     // Colors.cyan.shade100,
        //     // Colors.cyan.shade200,
        //     // Colors.lightBlue
        //     Color(0xffe9dfd4)
        //   ],
        // )),
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Color(
            0xffe9dfd4), // 0xffe9dfd4 Colors.transparent, //Colors.amber.shade700,
        title: FutureBuilder(
          future: _playlistFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Center(
                  child: Text(_playlist.name,
                      textScaleFactor: 2,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )));
            } else {
              return Container();
            }
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.home_filled),
              color: Colors.white,
              onPressed: () {
                Get.to(HomeUI());
              }),
        ],
      ),
      backgroundColor: Color(0xffe9dfd4), //Colors.transparent,
      body: Center(
          child: ListView(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Container(
                height: 300,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FutureBuilder(
                          future: _imagesFuture,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                width: 60.0,
                                height: 60.0,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (snapshot.hasData) {
                              // return Container(
                              //   decoration: BoxDecoration(
                              //     border: Border.all(
                              //       width: 5,
                              //     ),
                              //   ),
                              //   child: Image.network(_image),
                              // );
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
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: ElevatedButton(
                                    child: Text(
                                      _answerChoices[0],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    onPressed: buttonOneActive
                                        ? () async {
                                            guesses++;
                                            if (_answerChoices[0] ==
                                                correctAnswer) {
                                              s.stop();
                                              feedback(guesses);
                                              correctPlayer.play();
                                              var time = s.elapsedMilliseconds;
                                              buttonOne = ButtonStatus.correct;
                                              setAllButtonActivity(false);
                                              await Future.delayed(
                                                  Duration(seconds: 3));
                                              addRound(guesses, user,
                                                      time / 1000, songs[round])
                                                  .then((value) {
                                                rounds.add(value);
                                                scoring(guesses);
                                                if (round > 4) {
                                                  addGame(rounds, user)
                                                      .then((value) {
                                                    addScore(
                                                        value,
                                                        user,
                                                        date,
                                                        scores.reduce(
                                                            (a, b) => a + b));
                                                  });
                                                }
                                              });
                                              await correctPlayer.stop();
                                              progressRound(true);
                                            } else {
                                              incorrectPlayer.play();
                                              buttonOne =
                                                  ButtonStatus.incorrect;
                                              setState(() =>
                                                  buttonOneActive = false);
                                              await Future.delayed(
                                                  Duration(seconds: 1));
                                              await incorrectPlayer.stop();
                                            }
                                          }
                                        : () async {},
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              getColorOne),
                                      minimumSize:
                                          MaterialStateProperty.resolveWith(
                                              buttonSizing),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: ElevatedButton(
                                  child: Text(
                                    _answerChoices[1],
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  onPressed: buttonTwoActive
                                      ? () async {
                                          guesses++;
                                          if (_answerChoices[1] ==
                                              correctAnswer) {
                                            s.stop();
                                            feedback(guesses);
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
                                              scoring(guesses);
                                              if (round > 4) {
                                                addGame(rounds, user)
                                                    .then((value) {
                                                  addScore(
                                                      value,
                                                      user,
                                                      date,
                                                      scores.reduce(
                                                          (a, b) => a + b));
                                                });
                                              }
                                            });
                                            await correctPlayer.stop();
                                            progressRound(true);
                                          } else {
                                            incorrectPlayer.play();
                                            buttonTwo = ButtonStatus.incorrect;
                                            setState(
                                                () => buttonTwoActive = false);
                                            await Future.delayed(
                                                Duration(seconds: 1));
                                            await incorrectPlayer.stop();
                                          }
                                        }
                                      : () async {},
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            getColorTwo),
                                    minimumSize:
                                        MaterialStateProperty.resolveWith(
                                            buttonSizing),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    // child:
                                    child: ElevatedButton(
                                      child: Text(
                                        _answerChoices[2],
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      onPressed: buttonThreeActive
                                          ? () async {
                                              guesses++;
                                              if (_answerChoices[2] ==
                                                  correctAnswer) {
                                                s.stop();
                                                feedback(guesses);
                                                correctPlayer.play();
                                                var time =
                                                    s.elapsedMilliseconds;
                                                buttonThree =
                                                    ButtonStatus.correct;
                                                setAllButtonActivity(false);
                                                await Future.delayed(
                                                    Duration(seconds: 3));
                                                addRound(
                                                        guesses,
                                                        user,
                                                        time / 1000,
                                                        songs[round])
                                                    .then((value) {
                                                  rounds.add(value);
                                                  scoring(guesses);
                                                  if (round > 4) {
                                                    addGame(rounds, user)
                                                        .then((value) {
                                                      addScore(
                                                          value,
                                                          user,
                                                          date,
                                                          scores.reduce(
                                                              (a, b) => a + b));
                                                    });
                                                  }
                                                });
                                                await correctPlayer.stop();
                                                progressRound(true);
                                              } else {
                                                incorrectPlayer.play();
                                                buttonThree =
                                                    ButtonStatus.incorrect;
                                                setState(() =>
                                                    buttonThreeActive = false);
                                                await Future.delayed(
                                                    Duration(seconds: 1));
                                                await incorrectPlayer.stop();
                                              }
                                            }
                                          : () async {},
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                                getColorThree),
                                        minimumSize:
                                            MaterialStateProperty.resolveWith(
                                                buttonSizing),
                                      ),
                                    ),
                                  ),
                                ),
                                // Spacer(),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: ElevatedButton(
                                      child: Text(
                                        _answerChoices[3],
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      onPressed: buttonFourActive
                                          ? () async {
                                              guesses++;
                                              if (_answerChoices[3] ==
                                                  correctAnswer) {
                                                s.stop();
                                                feedback(guesses);
                                                correctPlayer.play();
                                                var time =
                                                    s.elapsedMilliseconds;
                                                buttonFour =
                                                    ButtonStatus.correct;
                                                setAllButtonActivity(false);
                                                await Future.delayed(
                                                    Duration(seconds: 3));
                                                addRound(
                                                        guesses,
                                                        user,
                                                        time / 1000,
                                                        songs[round])
                                                    .then((value) {
                                                  rounds.add(value);
                                                  scoring(guesses);
                                                  if (round > 4) {
                                                    addGame(rounds, user)
                                                        .then((value) {
                                                      addScore(
                                                          value,
                                                          user,
                                                          date,
                                                          scores.reduce(
                                                              (a, b) => a + b));
                                                    });
                                                  }
                                                });
                                                await correctPlayer.stop();
                                                progressRound(true);
                                              } else {
                                                incorrectPlayer.play();
                                                buttonFour =
                                                    ButtonStatus.incorrect;
                                                setState(() =>
                                                    buttonFourActive = false);
                                                await Future.delayed(
                                                    Duration(seconds: 1));
                                                await incorrectPlayer.stop();
                                              }
                                            }
                                          : () async {},
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                                getColorFour),
                                        minimumSize:
                                            MaterialStateProperty.resolveWith(
                                                buttonSizing),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
        ],
      )),
      bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Row(children: [
            Spacer(),
            IconButton(
                icon: Icon(Icons.skip_next_rounded),
                iconSize: 35,
                color: Colors.white,
                // labelText: "Skip",
                onPressed: skipActive
                    ? () async {
                        setAllButtonActivity(true);
                        progressRound(true);
                      }
                    : () async {}),
          ])),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple.shade300,
          child: FutureBuilder(
            future: _playlistFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Stack(
                  children: [
                    Container(
                        height: 1,
                        width: 1,
                        child: YoutubePlayerIFrame(
                          controller: _controller,
                          aspectRatio: 16 / 9,
                        )),
                    Icon(ppButtonStatus == VideoStatus.playing
                        ? Icons.pause
                        : Icons.play_arrow),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
          onPressed: () async {
            if (ppButtonStatus == VideoStatus.playing) {
              _controller.pause();
              setState(() {
                ppButtonStatus = VideoStatus.paused;
              });
            } else {
              _controller.play();
              setState(() {
                ppButtonStatus = VideoStatus.playing;
              });
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    ));
  }
}
