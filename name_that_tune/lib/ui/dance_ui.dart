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
  String correctAnswer = "";
  PlaylistModel _playlist;
  Future<PlaylistModel> _playlistFuture;
  dynamic _image;
  Future<String> _imagesFuture;
  List<SongModel> _songNames;
  YoutubePlayerController _controller;

  Status ppButtonStatus = Status.playing;

  @override
  void initState() {
    super.initState();
    _playlistFuture = initializePlaylist();
  }

  Future<PlaylistModel> initializePlaylist() async {
    _playlist = await convertPlaylistToUsable(data);
    songs = _playlist.songs;
    _songNames = await playlistToSongs(data);
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
    print(_playlist.songs);
    round++;
    // reset and update
    if (round <= 4) {
      if (skipVideo) {
        _controller.nextVideo();
      }
      setState(() {
        _imagesFuture = getImages();
        ppButtonStatus = Status.playing;
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
                  child: Text(_songNames[round].name,
                      textScaleFactor: 3,
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
                child: Center(
                  child: FutureBuilder(
                    future: _imagesFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        return Image.network(_image);
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ),
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
          child: Stack(children: [
            FutureBuilder(
              future: _playlistFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Container(
                      height: 1,
                      width: 1,
                      child: YoutubePlayerIFrame(
                        controller: _controller,
                        aspectRatio: 16 / 9,
                      ));
                } else {
                  return Container();
                }
              },
            ),
            Icon(ppButtonStatus == Status.playing
                ? Icons.pause
                : Icons.play_arrow),
          ]),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
