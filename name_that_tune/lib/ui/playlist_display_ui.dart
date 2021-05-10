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
        return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('songs').snapshots(),
            builder: (context, snapshot2) {
              if ((snapshot1.connectionState == ConnectionState.none &&
                      snapshot1.hasData == null) ||
                  (snapshot2.connectionState == ConnectionState.none &&
                      snapshot2.hasData == null)) {
                return Container();
              } else if (snapshot1.connectionState == ConnectionState.waiting ||
                  snapshot2.connectionState == ConnectionState.waiting) {
                return new Center(
                  child: new CircularProgressIndicator(),
                );
              }
              var streamData = {
                'image': snapshot1.data['image'],
                'name': snapshot1.data['name'],
                'songs': List<String>.from(snapshot1.data['songs']),
                'user': snapshot1.data['user'],
                'id': snapshot1.data.id
              };
              PlaylistWithID currentPlaylist =
                  PlaylistWithID.fromMap(streamData);
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

              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    onPressed: () async {
                      Get.back();
                    },
                  ),
                  title: Text(playlistData.name),
                  backgroundColor: Colors.lightBlue,
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
                        SongModel currentSong = customPlaylistSongs[index];
                        var imagelink = determineImage(currentSong.name);
                        return Column(
                          children: <Widget>[
                            ListTile(
                                leading: ClipRRect(
                                  child: Image.network(
                                    imagelink,
                                  ),
                                ),
                                title: Text(currentSong.name),
                                subtitle: Text(currentSong.artist),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTapDown: (TapDownDetails details) {
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
                ),
              );
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
            child: Text('Start'),
          )
        ],
      );
    } else {
      return ElevatedButton(
        child: Text('Start'),
        style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 50), primary: Colors.pink.shade300),
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

  determineImage(String playlistName) {
    var numberToCheck = playlistName.length * 9973;
    var numberToReturn = numberToCheck.toString()[1];
    var mappedNumbers = {
      '0': 0,
      '1': 1,
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 0,
      '6': 1,
      '7': 2,
      '8': 3,
      '9': 4
    };
    List<String> songImages = [
      'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/music(2).png?alt=media&token=bcfb50b3-bec0-4e82-a81b-9b33ff73ed1b',
      'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/music-note.png?alt=media&token=5861afc6-58c3-403b-99de-08d98a61eb77',
      'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/music(1).png?alt=media&token=cd275be6-5da0-4b78-ae31-12c3c09d5142',
      'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/music.png?alt=media&token=de62b676-1449-40cd-a5fb-a81b0a5eb6f7',
      'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/song.png?alt=media&token=9da7674b-3569-472c-b20a-36a339f77cee'
    ];
    return songImages[mappedNumbers[numberToReturn]];
  }
}
