import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

class PlaylistUI extends StatelessWidget {
  static const String _title = 'Playlists';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        body: PlaylistPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PlaylistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Navigation menu',
          onPressed: () async {
            Get.to(HomeUI());
          },
        ),
        title: Text('Playlists'),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.search),
          //   tooltip: 'Search',
          //   onPressed: null,
          // ),
        ],
      ),
      body: playlistWidget(),
    );
  }
}

Widget playlistWidget() {
  return FutureBuilder(
    builder: (context, projectSnap) {
      if (projectSnap.connectionState == ConnectionState.none &&
          projectSnap.hasData == null) {
        return Container();
      }
      return ListView.builder(
        itemCount: projectSnap.data.length,
        itemBuilder: (context, index) {
          PlaylistModel allPlaylists = projectSnap.data[index];
          return Column(
            children: <Widget>[
              // Displays list of projects in a tile
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    allPlaylists.image,
                    height: 100.0,
                    width: 100.0,
                  ),
                ),
                title: Text(allPlaylists.name),
                subtitle: Text('Public Playlist'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () async {
                  Get.to(SongUI(), arguments: allPlaylists.name);
                },
              ),
              Divider(thickness: 1),
            ],
          );
        },
      );
    },
    future: getAllPlaylists(),
  );
}
