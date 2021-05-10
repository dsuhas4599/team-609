import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/ui.dart';
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
  List<String> _songNames;
  YoutubePlayerController _controller;

  Status ppButtonStatus = Status.playing;
  bool skipActive = true;

  StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    _playlistFuture = initializePlaylist();
  }

  Future<PlaylistModel> initializePlaylist() async {
    _playlist = await convertPlaylistToUsable(data);
    _playlist.songs.shuffle();
    _playlist.songs = _playlist.songs.sublist(0, 5);
    songs = _playlist.songs;
    _songNames = await getSongNames(_playlist.songs);
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
      if (event.playerState == PlayerState.ended) {
        progressRound(false);
      }
    });
    setState(() {
      _imagesFuture = getImages();
    });
    return _playlist;
  }

  Future<String> getImages() async {
    _image = await videoIDToImage(songs[round]);
    return _image;
  }

  void progressRound(bool skipVideo) async {
    round++;
    // reset and update
    if (round <= 4) {
      if (skipVideo) {
        _controller.nextVideo();
      }
      setState(() {
        _imagesFuture = getImages();
        ppButtonStatus = Status.playing;
        skipActive = true;
      });
    } else {
      sub.cancel();
      Get.to(HomeUI());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: FutureBuilder(
          future: _playlistFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Center(
                  child: round <= 4
                      ? Text(_songNames[round],
                          textScaleFactor: 2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ))
                      : Text(""));
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
      backgroundColor: Color(0xffe9dfd4),
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
                        setState(() {
                          skipActive = false;
                        });
                        progressRound(true);
                      }
                    : () async {})
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
                    Icon(ppButtonStatus == Status.playing
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
