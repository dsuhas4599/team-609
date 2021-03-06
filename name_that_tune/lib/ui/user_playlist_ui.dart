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

class UserPlaylistUI extends StatefulWidget {
  @override
  _UserPlaylistUIState createState() => _UserPlaylistUIState();
}

class _UserPlaylistUIState extends State<UserPlaylistUI> {
  var songToAdd;

  @override
  void initState() {
    super.initState();
    songToAdd = Get.arguments;
  }

  final String user = auth.currentUser.uid.toString();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('playlists')
            .where('user', isEqualTo: user)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none &&
              snapshot.hasData == null) {
            return Container();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return new Center(
              child: new CircularProgressIndicator(),
            );
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
                  title: Text('My Playlists'),
                  backgroundColor: Colors.lightBlue),
              body: Column(
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      var currentPlaylist = snapshot.data.docs[index];
                      return Column(
                        children: <Widget>[
                          ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/playlist.png?alt=media&token=d4e48dc0-fa3e-4245-8549-770d3e1726c2',
                              ),
                            ),
                            title: Text(currentPlaylist['name']),
                            subtitle: Text(
                                (currentPlaylist['songs'].length).toString() +
                                    ' Songs'),
                            onTap: () {
                              _displayAddToPlaylist(
                                  context, songToAdd, currentPlaylist);
                            },
                          ),
                          Divider(thickness: 1),
                        ],
                      );
                    },
                  ))
                ],
              ));
        });
  }

  Future<void> _displayAddToPlaylist(
      BuildContext context, var songToAdd, var currentPlaylist) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add to this playlist?'),
          content: Text(
              'Add ' + songToAdd.name + ' to ' + currentPlaylist['name'] + '?'),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('ADD'),
              onPressed: () async {
                addSongToCurrentPlaylist(
                    currentPlaylist.id, songToAdd, context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
