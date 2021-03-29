import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:get/get.dart';

class SongUI extends StatefulWidget {
  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongUI> {
  var data = Get.arguments;
  String correctAnswer = "";
  int score = 0;
  PlaylistModel _playlist;
  Future<dynamic> _playlistFuture;
  List<dynamic> _images;
  Future<dynamic> _imagesFuture;
  List<String> _answerChoices;
  Future<dynamic> _answersFuture;
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    print(Get.arguments);
    _playlistFuture = initializePlaylist();
    _imagesFuture = getImages();
    _answersFuture = getAnswers();
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

  Future getImages() async {
    dynamic pl = await initializePlaylist();
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

  Future getAnswers() async {
    dynamic pl = await initializePlaylist();
    return createAnswerChoicesFromPlaylist(pl.songs[0], pl.name)
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
              _controller.nextVideo();
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
                                  labelText: _answerChoices[3],
                                  onPressed: () async {
                                    if (_answerChoices[0] == correctAnswer) {
                                      score++;
                                    }
                                    _controller.pause();
                                  })),
                          Expanded(
                              child: PrimaryButton(
                                  labelText: _answerChoices[1],
                                  onPressed: () async {
                                    if (_answerChoices[1] == correctAnswer) {
                                      score++;
                                    }
                                    _controller.pause();
                                  })),
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
                                    }
                                    _controller.pause();
                                  })),
                          Expanded(
                              child: PrimaryButton(
                                  labelText: _answerChoices[0],
                                  onPressed: () async {
                                    if (_answerChoices[3] == correctAnswer) {
                                      score++;
                                    }
                                    _controller.pause();
                                  })),
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
