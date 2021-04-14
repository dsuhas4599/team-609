// Functions for getting data from firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_starter/models/models.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference playlists =
    FirebaseFirestore.instance.collection('playlists');
CollectionReference songs = FirebaseFirestore.instance.collection('songs');
CollectionReference game = FirebaseFirestore.instance.collection('game');
CollectionReference rounds = FirebaseFirestore.instance.collection('rounds');
CollectionReference scores = FirebaseFirestore.instance.collection('scores');
CollectionReference images = FirebaseFirestore.instance.collection('images');
CollectionReference users = FirebaseFirestore.instance.collection('users');

// Answer choices
Future createAnswerChoices(String videoID) async {
  // returns 4 answer choices with the first one being the answer
  List<SongModel> allSongs = await getAllSongs();
  List<String> answerChoices = [];
  String correctChoice = allSongs
      .firstWhere((song) => song.videoID == videoID, orElse: () => SongModel())
      .name;
  answerChoices.add(correctChoice);
  allSongs.removeWhere((song) => song.videoID == videoID);
  allSongs.shuffle();
  allSongs.take(3).forEach((song) {
    answerChoices.add(song.name);
  });
  return answerChoices;
}

Future createAnswerChoicesFromPlaylist(String videoID, String playlist) async {
  // returns 4 answer choices from a given playlist
  List<SongModel> playlistSongs = await playlistToSongs(playlist);
  List<String> answerChoices = [];
  String correctChoice = playlistSongs
      .firstWhere((song) => song.videoID == videoID, orElse: () => SongModel())
      .name;
  answerChoices.add(correctChoice);
  playlistSongs.removeWhere((song) => song.videoID == videoID);
  playlistSongs.shuffle();
  playlistSongs.take(3).forEach((song) {
    answerChoices.add(song.name);
  });
  return answerChoices;
}

// Song functions
Future getAllSongs() async {
  // returns all songs in a list of song models
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
  // returns a list of all song names
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
  // returns a list of all playlists in firestore
  List<PlaylistModel> playlistObjects = [];
  await playlists.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          var data = {
            'user': doc['user'],
            'name': doc['name'],
            'songs': List<String>.from(doc['songs']),
            'image': doc['image']
          };
          playlistObjects.add(PlaylistModel.fromMap(data));
        })
      });
  return playlistObjects;
}

Future getSpecificPlaylist(String playlistName) async {
  // given a playlist name will return that playlist object
  List<PlaylistModel> allPlaylists = await getAllPlaylists();
  PlaylistModel currentPlaylist =
      allPlaylists.firstWhere((playlist) => playlist.name == playlistName);
  return currentPlaylist;
}

Future playlistToSongs(String playlist) async {
  // given a playlist object, will retrieve the list of songs from document ID
  PlaylistModel currentPlaylist = await getSpecificPlaylist(playlist);
  List<SongModel> playlistSongs = [];

  for (String songID in currentPlaylist.songs) {
    await songs.doc(songID).get().then((DocumentSnapshot documentSnapshot) {
      var data = {
        'artist': documentSnapshot.data()['artist'],
        'date': documentSnapshot.data()['date'],
        'name': documentSnapshot.data()['name'],
        'videoID': documentSnapshot.data()['videoID'],
      };
      playlistSongs.add(SongModel.fromMap(data));
    });
  }
  return playlistSongs;
}

Future convertPlaylistToUsable(String playlist) async {
  // given a playlist of songs doc references will return the same thing except with songs as videoIDs
  PlaylistModel currentPlaylist = await getSpecificPlaylist(playlist);
  PlaylistModel convertedPlaylist = currentPlaylist;
  List<String> convertedSongIDs = [];
  // set up initial playlist
  convertedPlaylist.name = currentPlaylist.name;
  convertedPlaylist.user = currentPlaylist.user;

  // convert song docs playlist into song videoID playlist
  for (String songID in currentPlaylist.songs) {
    await songs.doc(songID).get().then((DocumentSnapshot documentSnapshot) {
      convertedSongIDs.add(documentSnapshot.data()['videoID']);
    });
  }

  convertedPlaylist.songs = convertedSongIDs;
  return convertedPlaylist;
}

Future yearToImages(int year) async {
  // given a year, returns a list of image links
  var imageLinks = [];
  await images
      .where('year', isEqualTo: year)
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      imageLinks.add(doc['links']);
    });
  });
  return imageLinks;
}

//Functions to write to firestore
Future addGame(var rounds, var user) async {
  var valueid = "";
  await game.add({'rounds': rounds, 'user': user}).then(
      (value) => valueid = value.id);
  return valueid;
}

Future addRound(int guesses, var user, var time, var song) async {
  var valueid = "";
  await rounds
      .add({'user': user, 'guesses': guesses, 'song': song, 'time': time}).then(
          (value) {
    valueid = value.id;
  });
  return valueid;
}

Future<void> addScore(var game, var user, var date, var score) {
  return scores
      .add({'game': game, 'user': user, 'date': date, 'score': score})
      .then((value) => print("score added"))
      .catchError((error) => print("failed to add score"));
}

// All functions that are related to custom playlists
Future getCustomGlobalPlaylists(String user) async {
  List<PlaylistModel> customGlobalPlaylists = [];
  await playlists.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          var data = {
            'user': doc['user'],
            'name': doc['name'],
            'songs': List<String>.from(doc['songs']),
            'image': doc['image']
          };
          if (data['user'] == 'global' || data['user'] == user) {
            customGlobalPlaylists.add(PlaylistModel.fromMap(data));
          }
        })
      });
  return customGlobalPlaylists;
}

Future createEmptyPlaylist(String playlistName, String user) {
  var data = {
    'user': user,
    'songs': [],
    'name': playlistName,
    'image':
        'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/playlisticon.png?alt=media&token=774e6502-93e7-4de3-ada2-f3d676d70274'
  };
  return playlists.add(data);
}

Future findPlayer(String uid) async {
  await users.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          if (doc.id == uid) {
            return doc['name'];
          } else {
            return 'global';
          }
        })
      });
}

Future getPlaylistSongs(List<String> playlistSongs) async {
  List<SongModel> retrievedSongs = [];
  await songs.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          if (playlistSongs.contains(doc.id)) {
            var data = {
              'artist': doc['artist'],
              'date': doc['date'],
              'name': doc['name'],
              'videoID': doc['videoID']
            };
            retrievedSongs.add(SongModel.fromMap(data));
          }
        })
      });
  return retrievedSongs;
}
