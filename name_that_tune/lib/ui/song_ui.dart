import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_starter/models/models.dart';

SongModel song1 = SongModel(
  id: 1,
  name: 'Song',
  artist: 'Artist',
  api: 'IC5PL0XImjw');

SongModel song2 = SongModel(
  id: 2,
  name: 'Song',
  artist: 'Artist',
  api: 'AOMyS78o5YI'); 

PlaylistModel playlist1 = PlaylistModel(
  id: 1,
  name: 'simple playlist',
  songs: [song1.api, song2.api]);

class SongUI extends StatelessWidget {
  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: '',
    params: YoutubePlayerParams(
      playlist: playlist1.songs, // Defining custom playlist
      showControls: true,
      showFullscreenButton: true,
      autoPlay: true,
    ),
  );

  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ListView(
      children: <Widget>[
        Row(
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
        PrimaryButton(
            labelText: "Hide info",
            onPressed: () async {
              _controller.hideTopMenu();
              _controller.hidePauseOverlay();
            }),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 300,
            height: 300,
            child: YoutubePlayerIFrame(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
        ),
      ],
    )));
  }
}
