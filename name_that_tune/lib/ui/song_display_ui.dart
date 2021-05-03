import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

class SongDisplayUi extends StatefulWidget {
  // static const String _title = 'Songs';

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: _title,
  //     home: Scaffold(
  //       body: SongDisplayPage(),
  //     ),
  //     debugShowCheckedModeBanner: false,
  //   );
  // }
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
          tooltip: 'Navigation menu',
          onPressed: () async {
            Get.back();
          },
        ),
        title: Text('Songs'),
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
          if (value != null) addSongToCurrentPlaylist(playlistInfo.id, songData, topContext);
        });
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
                      // IconButton(
                      //   icon: Icon(Icons.more_horiz),
                      //   onPressed: () {
                      //     _displayTextInputDialog(context, 'asdf');
                      //   },
                      // ),
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _showPopupMenu(details.globalPosition, allSongs, playlistInfo);
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
