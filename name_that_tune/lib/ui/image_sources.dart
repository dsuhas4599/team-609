import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageSourcesUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thank you to these sources for the images in the game!"),
      ),
      body: ListView(
        children: [
          ListTile(
              title: Row(
            children: [
              Text("These sources were utilized under the following license: "),
              Linkify(
                text: "https://creativecommons.org/licenses/by/2.0/",
                onOpen: (link) async {
                  await launch(link.url);
                },
              ),
            ],
          )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("DLR German Aerospace Center: "),
                  Linkify(
                    text:
                        "https://commons.wikimedia.org/wiki/File:NASA_News_Center_Annex_and_VAB_(5664834225)_(2).jpg",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("Cliff: "),
                  Linkify(
                    text:
                        "https://www.flickr.com/photos/nostri-imago/2841227269",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("Infrogmation of New Orleans: "),
                  Linkify(
                    text:
                        "https://www.flickr.com/photos/infrogmation/6042027785",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("Elvis Galery: "),
                  Linkify(
                    text:
                        "https://www.flickr.com/photos/117123465@N06/12439301195",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("Janice Waltzer: "),
                  Linkify(
                    text: "https://www.flickr.com/photos/pixelpackr/50258404",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("East Coast Gambler: "),
                  Linkify(
                    text:
                        "https://www.flickr.com/photos/eastcoastgambler/13986881888",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("dave_7: "),
                  Linkify(
                    text: "https://www.flickr.com/photos/daveseven/7978356304",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("Rupert Colley: "),
                  Linkify(
                    text:
                        "https://www.flickr.com/photos/historyinanhour/4775027305",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("Ron Cogswell: "),
                  Linkify(
                    text:
                        "https://www.flickr.com/photos/22711505@N05/26030348612",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("Kevin Dooley: "),
                  Linkify(
                    text: "https://www.flickr.com/photos/pagedooley/4663391678",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              title: Row(
            children: [
              Text("These sources were utilized under the following license: "),
              Linkify(
                text: "https://creativecommons.org/publicdomain/mark/1.0/",
                onOpen: (link) async {
                  await launch(link.url);
                },
              ),
            ],
          )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text("Tullio Saba: "),
                  Linkify(
                    text:
                        "https://www.flickr.com/photos/97453745@N02/9307104144",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text(
                      "Warren K. Leffler and Library of Congress via pingnews: "),
                  Linkify(
                    text: "https://www.flickr.com/photos/pingnews/508689700",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
          ListTile(
              leading: Icon(Icons.fiber_manual_record),
              title: Row(
                children: [
                  Text(
                      "James R. Pearson and Department of Defense via pingnews: "),
                  Linkify(
                    text: "https://www.flickr.com/photos/pingnews/514620035",
                    onOpen: (link) async {
                      await launch(link.url);
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
