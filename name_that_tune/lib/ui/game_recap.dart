import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

class GameRecapUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "Finished!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                ),
                PrimaryButton(
                  labelText: "Back to Home",
                  onPressed: () async {
                    Get.to(HomeUI());
                  },
                )
              ],
            )));
  }
}
