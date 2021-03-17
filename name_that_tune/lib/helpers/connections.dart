// Functions for getting data from firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_starter/models/models.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference playlists = FirebaseFirestore.instance.collection('playlists');
CollectionReference songs = FirebaseFirestore.instance.collection('songs');
CollectionReference game = FirebaseFirestore.instance.collection('game');
CollectionReference rounds = FirebaseFirestore.instance.collection('rounds');
CollectionReference scores = FirebaseFirestore.instance.collection('scores');

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

//Functions to write to firestore
Future<void> addGame(var rounds, var user) {
  return game
    .add({
      'rounds': rounds, 
      'user': user
    })
    .then((value) => print("game added"))
    .catchError((error) => print("failed to add game"));
}

Future<void> addRound(int guesses, var user, var time, var song) {
  return game
    .add({
      'user': user,
      'guesses': guesses,
      'song': song,
      'time': time
    })
    .then((value) => print("round added"))
    .catchError((error) => print("failed to add round"));
}

Future<void> addScores(var game, var user, var date, var score) {
  return game
    .add({
      'game': game,
      'user': user,
      'date': date,
      'score': score
    })
    .then((value) => print("sccore added"))
    .catchError((error) => print("failed to add score"));
}