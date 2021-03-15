// Functions for getting data from firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_starter/models/models.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference playlists = FirebaseFirestore.instance.collection('playlists');
CollectionReference songs = FirebaseFirestore.instance.collection('songs');

// Song functions
Future getAllSongs() async {
  List<SongModel> songObjects = [];
  await songs.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          var data = {
            'artist': doc['artist'],
            'date': doc['date'],
            'name': doc['name'],
            'videoID': doc['videoID'],
          };
          songObjects.add(SongModel.fromMap(data));
        })
      });
   return songObjects;
}

Future getAllSongNames() async {
  List<String> songNames = [];
  await songs.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          songNames.add(doc['name']);
        })
      });
  return songNames;
}

// Playlist functions
Future getAllPlaylists() async {
  List<PlaylistModel> playlistObjects = [];
  await playlists.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          var data = {
            'user': doc['user'],
            'name': doc['name'],
            'songs': List<String>.from(doc['songs'])
          };
          playlistObjects.add(PlaylistModel.fromMap(data));
        })
      });
  return playlistObjects;
}