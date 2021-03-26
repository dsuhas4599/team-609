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
    _playlistFuture = getSpecificPlaylist(data).then((playlist) {
      print('finished playlist');
      print(playlist.songs.toString());
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
      _answersFuture =
          createAnswerChoicesFromPlaylist(_playlist.songs[0], _playlist.name)
              .then((answers) {
        print('finished answers');
        print(answers.toString());
        _answerChoices = answers;
        return answers;
      }).onError((error, stackTrace) {
        print(error);
        return error;
      });
      return playlist;
    }).onError((error, stackTrace) {
      print(error);
      return error;
    });
    _imagesFuture = yearToImages(1967).then((images) {
      print('finished images');
      print(images.toString());
      _images = images[0];
      return images;
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
                          print('progress indicator');
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          print('youtube widget');
                          print(_controller.params.playlist.toString());
                          return Container(
                              height: 300 /* change back to 0 */,
                              width: 300 /* change back to 0 */,
                              child: YoutubePlayerIFrame(
                                controller: _controller,
                                aspectRatio: 16 / 9,
                              ));
                        } else {
                          print('empty');
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
                          print('progress indicator');
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          print('images widget');
                          print(_images.toString());
                          return Image.network(_images[0]);
                        } else {
                          print('empty');
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
        new Center(
          child: FutureBuilder(
              future: _answersFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print('answers waiting');
                  return Container();
                } else if (snapshot.hasData) {
                  print('answers widget');
                  print(_answerChoices.toString());
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: PrimaryButton(
                                  labelText: "Temp Replacement for Null",
                                  onPressed: () async {
                                    _controller.pause();
                                  })),
                          Expanded(
                              child: PrimaryButton(
                                  labelText: _answerChoices[1],
                                  onPressed: () async {
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
                                    _controller.pause();
                                  })),
                          Expanded(
                              child: PrimaryButton(
                                  labelText: _answerChoices[0],
                                  onPressed: () async {
                                    _controller.pause();
                                  })),
                        ],
                      )
                    ],
                  );
                } else {
                  print('answers empty');
                  return Container();
                }
              }),
        )
      ],
    )));
  }
}
