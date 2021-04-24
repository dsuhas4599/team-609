import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class PlaylistDisplayUI extends StatefulWidget {
  @override
  _PlaylistDisplayUIState createState() => _PlaylistDisplayUIState();
}

class _PlaylistDisplayUIState extends State<PlaylistDisplayUI> {
  final String user = auth.currentUser.uid.toString();
  var playlistData = Get.arguments[0];
  var mode = Get.arguments[1];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playlist Songs',
      home: Scaffold(
        appBar: AppBar(
          title: Text(playlistData.name),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Navigation menu',
            onPressed: () async {
              Get.back();
            },
          ),
        ),
        body: buildEverything(playlistData, mode),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

Widget buildEverything(var playlistData, var mode) {
  return Column(
    children: <Widget>[
      playGameButton(playlistData, mode),
      Expanded(
        child: playlistSongsWidget(playlistData),
      )
    ],
  );
}

Widget playGameButton(var playlistData, var mode) {
  if (playlistData.songs.length == 0 || playlistData.songs.length < 5) {
    return Column(
      children: <Widget>[
        Text('Add some more songs!'),
        ElevatedButton(
          child: Text('Play Game'),
        )
      ],
    );
  } else {
    return ElevatedButton(
      child: Text('Play Game'),
      onPressed: () {
        if (mode == "dance") {
          Get.to(DanceUI(), arguments: playlistData.name);
        }
        else if (mode == "game") {
          Get.to(SongUI(), arguments: playlistData.name);
        }
      },
    );
  }
}

Widget playlistSongsWidget(var playlistData) {
  return FutureBuilder(
    builder: (context, projectSnap) {
      if (projectSnap.connectionState == ConnectionState.none &&
          projectSnap.hasData == null) {
        return Container();
      } else if (projectSnap.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      return ListView.builder(
        itemCount: projectSnap.data.length,
        itemBuilder: (context, index) {
          SongModel allSongs = projectSnap.data[index];
          return Column(
            children: <Widget>[
              // Displays list of songs in a tile
              ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/playlisticon.png?alt=media&token=774e6502-93e7-4de3-ada2-f3d676d70274',
                    ),
                  ),
                  title: Text(allSongs.name),
                  subtitle: Text(allSongs.artist),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {
                          // This will enable deletion of songs
                          // print('pressed ' + allSongs.videoID);
                        },
                      ),
                    ],
                  )),
              Divider(thickness: 1),
            ],
          );
        },
      );
    },
    future: getPlaylistSongs(playlistData.songs),
  );
}
