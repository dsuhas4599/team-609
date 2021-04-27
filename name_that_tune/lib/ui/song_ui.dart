import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';
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
      setState(() {
        _imagesFuture = getImages();
        _answersFuture = getAnswers();
      });
    } else {
      sub.cancel();
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
      return Colors.amber.shade700;
    }
  }

  Color getColorTwo(Set<MaterialState> states) {
    if (buttonTwo == ButtonStatus.correct) {
      return Colors.green;
    } else if (buttonTwo == ButtonStatus.incorrect) {
      return Colors.red;
    } else {
      return Colors.amber.shade700;
    }
  }

  Color getColorThree(Set<MaterialState> states) {
    if (buttonThree == ButtonStatus.correct) {
      return Colors.green;
    } else if (buttonThree == ButtonStatus.incorrect) {
      return Colors.red;
    } else {
      return Colors.amber.shade700;
    }
  }

  Color getColorFour(Set<MaterialState> states) {
    if (buttonFour == ButtonStatus.correct) {
      return Colors.green;
    } else if (buttonFour == ButtonStatus.incorrect) {
      return Colors.red;
    } else {
      return Colors.amber.shade700;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12, //Colors.amber.shade700,
        title: Text(_playlist.name),
        actions: <Widget>[],
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: ListView(
        children: <Widget>[
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
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                child: Text(_answerChoices[0]),
                                onPressed: buttonOneActive
                                    ? () async {
                                        guesses++;
                                        if (_answerChoices[0] ==
                                            correctAnswer) {
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
                                          buttonOne = ButtonStatus.incorrect;
                                          setState(
                                              () => buttonOneActive = false);
                                          await Future.delayed(
                                              Duration(seconds: 1));
                                          await incorrectPlayer.stop();
                                        }
                                      }
                                    : () async {},
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            getColorOne)),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                child: Text(_answerChoices[1]),
                                onPressed: buttonTwoActive
                                    ? () async {
                                        guesses++;
                                        if (_answerChoices[1] ==
                                            correctAnswer) {
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
                                            getColorTwo)),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                child: Text(_answerChoices[2]),
                                onPressed: buttonThreeActive
                                    ? () async {
                                        guesses++;
                                        if (_answerChoices[2] ==
                                            correctAnswer) {
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
                                          buttonThree = ButtonStatus.incorrect;
                                          setState(
                                              () => buttonThreeActive = false);
                                          await Future.delayed(
                                              Duration(seconds: 1));
                                          await incorrectPlayer.stop();
                                        }
                                      }
                                    : () async {},
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            getColorThree)),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                child: Text(_answerChoices[3]),
                                onPressed: buttonFourActive
                                    ? () async {
                                        guesses++;
                                        if (_answerChoices[3] ==
                                            correctAnswer) {
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
                                          buttonFour = ButtonStatus.incorrect;
                                          setState(
                                              () => buttonFourActive = false);
                                          await Future.delayed(
                                              Duration(seconds: 1));
                                          await incorrectPlayer.stop();
                                        }
                                      }
                                    : () async {},
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            getColorFour)),
                              ),
                            )
                          ],
                        )
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
          color: Colors.black12,
          child: Row(children: [
            Spacer(),
            IconButton(
                icon: Icon(Icons.skip_next_rounded),
                iconSize: 40,
                color: Colors.white,
                // labelText: "Skip",
                onPressed: () async {
                  progressRound(true);
                }),
          ])),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          child: Icon(ppButtonStatus == VideoStatus.playing
              ? Icons.pause
              : Icons.play_arrow),
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
    );
  }
}
