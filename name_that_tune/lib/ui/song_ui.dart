import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';

class SongUI extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PrimaryButton(
          labelText: "Press to play song", onPressed: () async {}),)
    );
  }
}
