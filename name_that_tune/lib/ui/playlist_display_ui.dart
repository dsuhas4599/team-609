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
  var _allSongs;

  @override
  void initState() {
    super.initState();
    _allSongs = getPlaylistSongs(playlistData.songs);
  }

  final String user = auth.currentUser.uid.toString();
  var playlistData = Get.arguments;

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
          actions: <Widget>[
            determineCustomPlaylist(playlistData),
          ],
        ),
        body: buildEverything(playlistData),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget playlistSongsWidget(var playlistData) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none &&
            projectSnap.hasData == null) {
          return Container();
        } else if (projectSnap.connectionState == ConnectionState.waiting) {
          return new Center(
            child: new CircularProgressIndicator(),
          );
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
      future: _allSongs,
    );
  }

  Widget buildEverything(var playlistData) {
    return Column(
      children: <Widget>[
        playGameButton(playlistData),
        Expanded(
          child: playlistSongsWidget(playlistData),
        )
      ],
    );
  }

  Widget playGameButton(var playlistData) {
    if (playlistData.songs.length == 0 || playlistData.songs.length < 4) {
      return Column(
        children: <Widget>[
          Text('Add some more songs!'),
          Text('You need at least 5 songs'),
          ElevatedButton(
            child: Text('Play Game'),
          )
        ],
      );
    } else {
      return ElevatedButton(
        child: Text('Play Game'),
        onPressed: () {
          Get.to(SongUI(), arguments: playlistData.name);
        },
      );
    }
  }

  Widget determineCustomPlaylist(var playlistInfo) {
    // var displayName =  findPlayer(user);
    if (playlistInfo.user != 'global') {
      return GestureDetector(
        onTapDown: (TapDownDetails details) {
          _showPopupMenu(details.globalPosition, playlistInfo);
        },
        child: IconButton(icon: Icon(Icons.more_horiz)),
      );
      // IconButton(
      //   icon: Icon(Icons.add),
      //   tooltip: 'Add Playlist',
      //   onPressed: () {
      //     Get.to(SongDisplayUi(), arguments: playlistInfo);
      //   },
      // );
    } else {
      return new Container();
    }
  }

  // misc functions
  void refreshSongList() {
    setState(() {
      _allSongs = getPlaylistSongs(playlistData.songs);
    });
  }

  _showPopupMenu(Offset offset, var playlistData) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem(
          value: 1,
          child: Text("Add Songs"),
        ),
        PopupMenuItem(
          value: 2,
          child: Text("Delete Playlist"),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        if (value == 1) {
          Get.to(SongDisplayUi(), arguments: playlistData);
        } else if (value == 2) {
          deleteCustomPlaylist(playlistData);
          Get.back();
        }
      }
    });
  }
}
