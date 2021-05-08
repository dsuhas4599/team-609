import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class PlaylistDisplayUI extends StatefulWidget {
  @override
  _PlaylistDisplayUIState createState() => _PlaylistDisplayUIState();
}

class _PlaylistDisplayUIState extends State<PlaylistDisplayUI> {
  var playlistData;
  var mode = Get.arguments[1];
  @override
  void initState() {
    super.initState();
    playlistData = Get.arguments[0];
  }

  final String user = auth.currentUser.uid.toString();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistData.id)
          .snapshots(),
      builder: (context, snapshot1) {
        // Convert to real time playlist data
        var streamData = {
          'image': snapshot1.data['image'],
          'name': snapshot1.data['name'],
          'songs': List<String>.from(snapshot1.data['songs']),
          'user': snapshot1.data['user'],
          'id': snapshot1.data.id
        };
        PlaylistWithID currentPlaylist = PlaylistWithID.fromMap(streamData);

        return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('songs').snapshots(),
            builder: (context, snapshot2) {
              if (snapshot1.connectionState == ConnectionState.none &&
                  snapshot1.hasData == null) {
                return Container();
              } else if (snapshot1.connectionState == ConnectionState.waiting) {
                return new Center(
                  child: new CircularProgressIndicator(),
                );
              }

              // Set song data to be displayed
              List<SongWithID> customPlaylistSongs = [];
              for (var songData in snapshot2.data.docs) {
                var data = {
                  'artist': songData['artist'],
                  'date': songData['date'],
                  'name': songData['name'],
                  'videoID': songData['videoID'],
                  'id': songData.id
                };

                if (snapshot1.data['songs'].contains(songData.id)) {
                  customPlaylistSongs.add(SongWithID.fromMap(data));
                }
              }

              return MaterialApp(
                  debugShowCheckedModeBanner: false,
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
                      body: Column(
                        children: <Widget>[
                          playGameButton(customPlaylistSongs),
                          Expanded(
                              child: ListView.builder(
                            itemCount: customPlaylistSongs.length,
                            itemBuilder: (context, index) {
                              SongModel currentSong =
                                  customPlaylistSongs[index];
                              return Column(
                                children: <Widget>[
                                  ListTile(
                                      leading: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/playlisticon.png?alt=media&token=774e6502-93e7-4de3-ada2-f3d676d70274',
                                        ),
                                      ),
                                      title: Text(currentSong.name),
                                      subtitle: Text(currentSong.artist),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTapDown:
                                                (TapDownDetails details) {
                                              _specificSongPopUp(
                                                  details.globalPosition,
                                                  currentPlaylist,
                                                  currentSong);
                                            },
                                            child: IconButton(
                                                icon: Icon(Icons.more_horiz)),
                                          )
                                        ],
                                      )),
                                ],
                              );
                            },
                          ))
                        ],
                      )));
            });
      },
    );
  }

  Widget playGameButton(var listOfSongs) {
    if (listOfSongs.length == 0 || listOfSongs.length < 5) {
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
          if (mode == "game") {
            Get.to(SongUI(), arguments: playlistData.name);
          } else if (mode == "dance") {
            Get.to(DanceUI(), arguments: playlistData.name);
          }
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
    } else {
      return new Container();
    }
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

  _specificSongPopUp(
      Offset offset, PlaylistWithID playlistData, var songToSend) async {
    double left = offset.dx;
    double top = offset.dy;
    if (playlistData.user == 'global') {
      await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(left, top, 0, 0),
        items: [
          PopupMenuItem(
            value: 1,
            child: Text("Add to Playlist"),
          ),
        ],
        elevation: 8.0,
      ).then((value) async {
        if (value != null) {
          if (value == 1) {
            Get.to(UserPlaylistUI(), arguments: songToSend);
          }
        }
      });
    } else {
      await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(left, top, 0, 0),
        items: [
          PopupMenuItem(value: 1, child: Text("Add to Playlist")),
          PopupMenuItem(
            value: 2,
            child: Text("Delete Song"),
          )
        ],
        elevation: 8.0,
      ).then((value) async {
        if (value != null) {
          if (value == 1) {
            Get.to(UserPlaylistUI(), arguments: songToSend);
          } else if (value == 2) {
            await deleteSongInCustomPlaylist(playlistData, songToSend);
          }
        }
      });
    }
  }
}
