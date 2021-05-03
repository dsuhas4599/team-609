import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

enum Status { playing, paused }

class DanceUI extends StatefulWidget {
  @override
  _DancePageState createState() => _DancePageState();
}

class _DancePageState extends State<DanceUI> {
  int round = 0;
  var songs = [];
  var data = Get.arguments;
  PlaylistModel _playlist;
  Future<PlaylistModel> _playlistFuture;
  dynamic _image;
  Future<String> _imagesFuture;
  YoutubePlayerController _controller;

  Status ppButtonStatus = Status.playing;


  @override
  void initState() {
    super.initState();
    _playlistFuture = initializePlaylist();
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
    setState(() {
      _imagesFuture = getImages();
    });
    return _playlist;
  }

  Future<String> getImages() async {
    _image = await videoIDToImage(songs[round]);
    return _image;
  }

  void progressRound(bool skipVideo) {
    round++;
    // reset and update
    if (round <= 4) {
      if (skipVideo) {
        _controller.nextVideo();
      }
      setState(() {
        _imagesFuture = getImages();
      });
    } else {
      Get.to(HomeUI());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12, //Colors.amber.shade700,
        title: FutureBuilder(
          future: _playlistFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Center(
                  child: Text(_playlist.name,
                      textScaleFactor: 4,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )));
            } else {
              return Container();
            }
          },
        ),
        actions: <Widget>[],
      ),
      body: Center(
        child: ListView(
        children: <Widget>[
          PrimaryButton(
            labelText: ppButtonStatus == Status.playing ? "Pause" : "Play",
            onPressed: () async {
              if (ppButtonStatus == Status.playing) {
                _controller.pause();
                setState(() {
                  ppButtonStatus = Status.paused;
                });
              } else {
                _controller.play();
                setState(() {
                  ppButtonStatus = Status.playing;
                });
              }
            }),
          PrimaryButton(
            labelText: "Skip song",
            onPressed: () async {
              progressRound(true);
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
      ],
    )));
  }
}