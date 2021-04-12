import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

final FirebaseAuth auth = FirebaseAuth.instance;

class PlaylistPage extends StatelessWidget {
  final String user = auth.currentUser.uid.toString();

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
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Playlist',
            onPressed: () {
              _displayTextInputDialog(context, user);
            },
          ),
        ],
      ),
      body: playlistWidget(user),
    );
  }
}

Widget playlistWidget(String user) {
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
    future: getCustomGlobalPlaylists(user),
  );
}

// Add empty playlist dialog box
TextEditingController _textFieldController = TextEditingController();
Future<void> _displayTextInputDialog(BuildContext context, String user) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Name your playlist!'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "My playlist"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
                print(user);
              },
            ),
            TextButton(
              child: Text('CREATE'),
              onPressed: () {
                createEmptyPlaylist(_textFieldController.text, user);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
