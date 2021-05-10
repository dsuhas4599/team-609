import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

class SongDisplayUi extends StatefulWidget {
  @override
  _SongDisplayPageState createState() => _SongDisplayPageState();
}

class _SongDisplayPageState extends State<SongDisplayUi> {
  var playlistInfo = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () async {
            Get.back();
          },
        ),
        title: Text('Songs'),
        backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.add),
          //   tooltip: 'Add Playlist',
          //   onPressed: () {
          //     print('added');
          //   },
          // ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   tooltip: 'Add', // used by assistive technologies
      //   child: Icon(Icons.add),
      //   onPressed: null,
      // ),
      body: songDisplayWidget(context, playlistInfo),
    );
  }
}

Widget songDisplayWidget(BuildContext topContext, var playlistInfo) {
  return FutureBuilder(
    builder: (context, projectSnap) {
      if (projectSnap.connectionState == ConnectionState.none &&
          projectSnap.hasData == null) {
        return Container();
      } else if (projectSnap.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      _showPopupMenu(Offset offset, var songData, var playlistInfo) async {
        double left = offset.dx;
        double top = offset.dy;
        await showMenu(
          context: context,
          position: RelativeRect.fromLTRB(left, top, 0, 0),
          items: [
            PopupMenuItem(
              value: 1,
              child: Text("Add to Current Playlist"),
            ),
          ],
          elevation: 8.0,
        ).then((value) {
          if (value != null)
            addSongToCurrentPlaylist(playlistInfo.id, songData, topContext);
        });
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

      return ListView.builder(
        itemCount: projectSnap.data.length,
        itemBuilder: (context, index) {
          SongModel allSongs = projectSnap.data[index];
          var imagelink = determineImage(allSongs.name);
          return Column(
            children: <Widget>[
              // Displays list of songs in a tile
              ListTile(
                  leading: ClipRRect(
                    child: Image.network(
                      imagelink,
                    ),
                  ),
                  title: Text(allSongs.name),
                  subtitle: Text(allSongs.artist),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _showPopupMenu(
                              details.globalPosition, allSongs, playlistInfo);
                        },
                        child: IconButton(icon: Icon(Icons.more_horiz)),
                      ),
                    ],
                  )
                  // onTap: () async {
                  //   Get.to(SongUI(), arguments: allPlaylists.name);
                  // },
                  ),
              Divider(thickness: 1),
            ],
          );
        },
      );
    },
    future: getSongsWithIDs(),
  );
}
