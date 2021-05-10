import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/playlist_display_ui.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaylistUI extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

final FirebaseAuth auth = FirebaseAuth.instance;

class _PlaylistPageState extends State<PlaylistUI> {
  final String user = auth.currentUser.uid.toString();
  var _allPlaylists;
  var mode = Get.arguments;

  @override
  void initState() {
    super.initState();
    // _allPlaylists = streamCustomPlaylists(user);
    _allPlaylists =
        FirebaseFirestore.instance.collection('playlists').snapshots();
  }

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
        title: Text('Playlists'),
        backgroundColor: Colors.lightBlue,
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

  Widget playlistWidget(String user) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('playlists')
          .where('user', whereIn: [user, 'global']).snapshots(),
      initialData: [],
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
          itemCount: projectSnap.data.docs.length,
          itemBuilder: (context, index) {
            var currentDoc = projectSnap.data.docs[index];
            var data = {
              'user': currentDoc['user'],
              'name': currentDoc['name'],
              'songs': List<String>.from(currentDoc['songs']),
              'image': currentDoc['image'],
              'id': currentDoc.id
            };
            PlaylistWithID currentPlaylist = PlaylistWithID.fromMap(data);
            return Column(
              children: <Widget>[
                // Displays list of playlists in a tile
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/playlist.png?alt=media&token=d4e48dc0-fa3e-4245-8549-770d3e1726c2',
                      height: 50.0,
                      width: 50.0,
                    ),
                  ),
                  title: Text(currentPlaylist.name),
                  subtitle: determineSubtitle(currentPlaylist.user),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    var arg = [currentPlaylist, mode];
                    Get.to(PlaylistDisplayUI(), arguments: arg);
                  },
                ),
                Divider(thickness: 1),
              ],
            );
          },
        );
      },
    );
  }

// Add empty playlist dialog box
  TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(
      BuildContext context, String user) async {
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
              },
            ),
            TextButton(
              child: Text('CREATE'),
              onPressed: () {
                createEmptyPlaylist(_textFieldController.text, user);
                refreshPlaylists();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget determineSubtitle(String user) {
    // var displayName =  findPlayer(user);
    if (user == 'global') {
      return Text('Public Playlist');
    } else {
      return Text('Custom Playlist');
    }
  }

  // misc functions
  void refreshPlaylists() {
    setState(() {
      _allPlaylists = getCustomGlobalPlaylists(user);
    });
  }
}
