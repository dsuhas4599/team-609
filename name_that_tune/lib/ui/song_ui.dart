import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_starter/helpers/helpers.dart';

class SongUI extends StatefulWidget {
  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongUI> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hideInfo());
  }

  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: '',
    params: YoutubePlayerParams(
      playlist: [
        'IC5PL0XImjw',
        'AOMyS78o5YI',
        'plcmqP3b-Qg',
        'TWoFl_0UtjQ',
      ], // Defining custom playlist
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Expanded(
            //   child: PrimaryButton(
            //       labelText: "Play",
            //       onPressed: () async {
            //         _controller.play();
            //       }),
            // ),
            // Expanded(
            //   child: PrimaryButton(
            //       labelText: "Pause",
            //       onPressed: () async {
            //         _controller.pause();
            //       }),
            // ),
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: 300,
              height: 300,
              child: YoutubePlayerIFrame(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ),
        new Row(children: <Widget>[
          Expanded(
            child: PrimaryButton(
                labelText: "Brown Eyed Girl",
                onPressed: () async {
                  _controller.pause();
                }),
          ),
          Expanded(
            child: PrimaryButton(
                labelText: "Ain't No Mountain High Enough",
                onPressed: () async {
                  _controller.pause();
                }),
          ),
        ]),
        new Row(children: <Widget>[
          Expanded(
            child: PrimaryButton(
                labelText: "God Only Knows",
                onPressed: () async {
                  _controller.pause();
                }),
          ),
          Expanded(
            child: PrimaryButton(
                labelText: "My Girl",
                onPressed: () async {
                  _controller.pause();
                }),
          ),
        ]),
      ],
    )));
  }

  _hideInfo() {
    _controller.hideTopMenu();
    _controller.hidePauseOverlay();
  }
}
