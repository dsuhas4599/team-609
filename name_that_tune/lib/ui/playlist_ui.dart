import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

class PlaylistUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: PrimaryButton(
        labelText: 'Pull Playlist and Start the Game',
        onPressed: () async {
          Get.to(SongUI(), arguments: "test playlist");
        },
      ),
    ));
  }
}
