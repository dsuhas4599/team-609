import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

// getCustomGlobalPlaylists
// addSongToCurrentPlaylist
// getPlaylistFromID

// getGlobalPlaylists
// addSong
// addSongToGlobalPlaylist

class AddSongUI extends StatefulWidget {
  @override
  _AddSongState createState() => _AddSongState();
}

class _AddSongState extends State<AddSongUI> {
  final _formKey = GlobalKey<FormState>();
  final TextStyle labelStyle = TextStyle(fontSize: 24, color: Colors.black);
  Future<List<PlaylistModel>> _playlistsFuture;
  List<PlaylistModel> playlists;
  PlaylistModel dropdownValue;
  final artistController = TextEditingController();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final videoIDController = TextEditingController();
  FocusNode topFocus;

  @override
  void initState() {
    super.initState();
    _playlistsFuture = loadPlaylists();
    topFocus = FocusNode();
    topFocus.requestFocus();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    artistController.dispose();
    dateController.dispose();
    nameController.dispose();
    videoIDController.dispose();
    topFocus.dispose();
    super.dispose();
  }

  Future<List<PlaylistModel>> loadPlaylists() async {
    playlists = await getGlobalPlaylists();
    dropdownValue = playlists.first;
    return playlists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Add Song",
          ),
          actions: <Widget>[],
        ),
        body: Form(
            key: _formKey,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: 2,
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      //artist
                      Text("Artist Name", style: labelStyle),
                      TextFormField(
                        controller: artistController,
                        focusNode: topFocus,
                        decoration: InputDecoration(
                            fillColor: Colors.white, filled: true),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      FormVerticalSpace(),
                      //date
                      Text("Release Year", style: labelStyle),
                      TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                            fillColor: Colors.white, filled: true),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      FormVerticalSpace(),
                      //name
                      Text("Song Name", style: labelStyle),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                            fillColor: Colors.white, filled: true),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      FormVerticalSpace(),
                      //videoID
                      Text("Youtube Video ID", style: labelStyle),
                      TextFormField(
                        controller: videoIDController,
                        decoration: InputDecoration(
                            fillColor: Colors.white, filled: true),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      FormVerticalSpace(),
                    ],
                  ),
                ),
                //playlist - dropdown
                Expanded(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: FutureBuilder(
                            future: _playlistsFuture,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return DropdownButton(
                                  value: dropdownValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      dropdownValue = newValue;
                                    });
                                  },
                                  items: playlists
                                      .map<DropdownMenuItem<PlaylistModel>>(
                                          (PlaylistModel model) {
                                    return DropdownMenuItem<PlaylistModel>(
                                        value: model, child: Text(model.name));
                                  }).toList(),
                                  style: labelStyle,
                                  dropdownColor: Colors.white,
                                );
                              } else {
                                return Container();
                              }
                            })))
              ],
            )),
        bottomNavigationBar: SizedBox(
          height: 50,
          child: BottomAppBar(
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState.validate()) {
                  // add song to songs
                  DocumentReference addedSongRef = await addSong(
                      artistController.text,
                      dateController.text,
                      nameController.text,
                      videoIDController.text);
                  // add song doc id to playlist.songs
                  DocumentSnapshot addedSongSnap = await addedSongRef.get();
                  String addedSongID = addedSongSnap.id;
                  addSongToGlobalPlaylist(addedSongID, dropdownValue.name)
                      .then((value) {
                    artistController.clear();
                    dateController.clear();
                    nameController.clear();
                    videoIDController.clear();
                    topFocus.requestFocus();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Successfully added to database and playlist')));
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Errors: Check database for issues')));
                  });
                }
              },
              child: Text('Submit'),
            ),
          ),
        ));
  }
}
