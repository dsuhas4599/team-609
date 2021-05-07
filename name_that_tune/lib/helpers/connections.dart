// Functions for getting data from firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter/material.dart';

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
Future<List<String>> createAnswerChoices(String videoID) async {
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

Future<List<String>> createAnswerChoicesFromPlaylist(
    String videoID, String playlist) async {
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
Future<List<SongModel>> getAllSongs() async {
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

Future<List<String>> getAllSongNames() async {
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
Future<List<PlaylistModel>> getAllPlaylists() async {
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

Future<List<PlaylistModel>> getGlobalPlaylists() async {
  // returns a list of all global playlists in firestore
  List<PlaylistModel> playlistObjects = [];
  await playlists.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          var data = {
            'user': doc['user'],
            'name': doc['name'],
            'songs': List<String>.from(doc['songs']),
            'image': doc['image']
          };
          if (PlaylistModel.fromMap(data).user == "global") {
            playlistObjects.add(PlaylistModel.fromMap(data));
          }
        })
      });
  return playlistObjects;
}

Future<PlaylistModel> getSpecificPlaylist(String playlistName) async {
  // given a playlist name will return that playlist object
  List<PlaylistModel> allPlaylists = await getAllPlaylists();
  PlaylistModel currentPlaylist =
      allPlaylists.firstWhere((playlist) => playlist.name == playlistName);
  return currentPlaylist;
}

Future<List<SongModel>> playlistToSongs(String playlist) async {
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

Future<PlaylistModel> convertPlaylistToUsable(String playlist) async {
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

Future<List<dynamic>> yearToImages(int year) async {
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

Future<String> videoIDToImage(String id) async {
  // given a song's video id, returns a list of images from the year of that song
  var imageLinks = [];
  String songYear = "";
  bool displayTemp = false;
  await songs.where('videoID', isEqualTo: id).get().then((QuerySnapshot qs) {
    qs.docs.forEach((song) {
      songYear = song['date'];
    });
  });
  await images
      .where('year', isEqualTo: songYear)
      .get()
      .then((QuerySnapshot qs) {
    if (qs.docs.isEmpty) {
      displayTemp = true;
    } else {
      qs.docs.forEach((doc) {
        imageLinks.add(doc['links']);
      });
    }
  });
  if (displayTemp) {
    return "https://combo.staticflickr.com/ap/build/images/refencing-announcement/bird2.jpg";
    //return "https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/playlisticon.png?alt=media&token=774e6502-93e7-4de3-ada2-f3d676d70274";
  } else {
    List<dynamic> imagesList = imageLinks[0];
    imagesList.shuffle();
    return imagesList.first;
  }
}

//Functions to write to firestore
Future<String> addGame(var rounds, var user) async {
  var valueid = "";
  await game.add({'rounds': rounds, 'user': user}).then(
      (value) => valueid = value.id);
  return valueid;
}

Future<String> addRound(int guesses, var user, var time, var song) async {
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

Future<DocumentReference> addSong(
    String artist, String date, String name, String videoID) async {
  DocumentReference docRef = await songs.add({
    'artist': artist,
    'date': date,
    'name': name,
    'videoID': videoID,
  });
  return docRef;
}

// Inherited model for playlist with IDs
class PlaylistWithID extends PlaylistModel {
  String id;

  PlaylistWithID({user, name, songs, image, this.id})
      : super(user: user, name: name, songs: songs, image: image);
  // factory PlaylistWithID.fromJson(Map<String, dynamic> toJson() => {"user": user, "name": name, "songs": songs, "image": image};)
  factory PlaylistWithID.fromMap(Map data) {
    return PlaylistWithID(
      user: data['user'] ?? '',
      name: data['name'] ?? '',
      songs: data['songs'] ?? '',
      image: data['image'] ?? '',
      id: data['id'] ?? '',
    );
  }
}

// All functions that are related to custom playlists
Future<List<PlaylistModel>> getCustomGlobalPlaylists(String user) async {
  List<PlaylistModel> customGlobalPlaylists = [];
  await playlists.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          var data = {
            'user': doc['user'],
            'name': doc['name'],
            'songs': List<String>.from(doc['songs']),
            'image': doc['image'],
            'id': doc.id
          };
          if (data['user'] == 'global' || data['user'] == user) {
            customGlobalPlaylists.add(PlaylistWithID.fromMap(data));
          }
        })
      });
  return customGlobalPlaylists;
}

Future<void> createEmptyPlaylist(String playlistName, String user) {
  var data = {
    'user': user,
    'songs': [],
    'name': playlistName,
    'image':
        'https://firebasestorage.googleapis.com/v0/b/careyaya-name-that-tune.appspot.com/o/playlisticon.png?alt=media&token=774e6502-93e7-4de3-ada2-f3d676d70274'
  };
  return playlists.add(data);
}

Future<void> findPlayer(String uid) async {
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

Future<List<String>> getSongNames(List<String> songIDs) async {
  List<String> songNames = [];
  for (var i = 0; i < 5; i ++) {
    await songs.get().then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) { 
        if (songIDs[i] == doc['videoID']) {
          songNames.add(doc['name']);
        }
      })
    });
  }
  return songNames;
}

Future<List<SongModel>> getPlaylistSongs(List<String> playlistSongs) async {
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

Future<void> addSongToCurrentPlaylist(
    String id, var songData, BuildContext context) async {
  await playlists.doc(id).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.data()['songs'].contains(songData.id)) {
      _displayCreated(context);
    } else {
      playlists.doc(id).update({
        "songs": FieldValue.arrayUnion([songData.id])
      });
    }
  });
}

Future<void> addSongToGlobalPlaylist(String songID, String playlistName) async {
  await playlists
      .where("name", isEqualTo: playlistName)
      .get()
      .then((QuerySnapshot snap) {
    if (snap.docs.length == 1) {
      playlists.doc(snap.docs.first.id).update({
        "songs": FieldValue.arrayUnion([songID])
      });
    }
  });
}

// Inherited model for songs with IDs
class SongWithID extends SongModel {
  String id;

  SongWithID({artist, date, name, videoID, this.id})
      : super(artist: artist, date: date, name: name, videoID: videoID);

  factory SongWithID.fromMap(Map data) {
    return SongWithID(
      artist: data['artist'] ?? '',
      date: data['date'] ?? '',
      name: data['name'] ?? '',
      videoID: data['videoID'] ?? '',
      id: data['id'] ?? '',
    );
  }
}

// Song functions
Future<List<SongWithID>> getSongsWithIDs() async {
  // returns all songs in a list of song models including IDs for easier db manipulation
  List<SongWithID> songObjects = [];
  await songs.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          var data = {
            'artist': doc['artist'],
            'date': doc['date'],
            'name': doc['name'],
            'videoID': doc['videoID'],
            'id': doc.id
          };
          songObjects.add(SongWithID.fromMap(data));
        })
      });
  return songObjects;
}

Future<List<SongWithID>> getCustomSongsWithIDs(
    List<String> playlistSongs) async {
  // returns list of songs of a custom playlist with all IDs
  List<SongWithID> retrievedSongs = [];
  await songs.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          if (playlistSongs.contains(doc.id)) {
            var data = {
              'artist': doc['artist'],
              'date': doc['date'],
              'name': doc['name'],
              'videoID': doc['videoID'],
              'id': doc.id
            };
            retrievedSongs.add(SongWithID.fromMap(data));
          }
        })
      });
  return retrievedSongs;
}

// Misc. Alert
Future<void> _displayCreated(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('This song is already added to this playlist!'),
        actions: <Widget>[
          TextButton(
            child: Text('OKAY'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

Future<void> deleteCustomPlaylist(PlaylistWithID playlistData) async {
  return playlists
      .doc(playlistData.id)
      .delete()
      .then((value) => print("Playlist deleted"))
      .catchError((error) => print("Failed to delete playlist: $error"));
}

Future<void> deleteSongInCustomPlaylist(var playlistData, var allSongs) async {
  return playlists
      .doc(playlistData.id)
      .update({
        'songs': FieldValue.arrayRemove([allSongs.id])
      })
      .then((value) => print("Song deleted"))
      .catchError((error) => print("Failed to delete song: $error"));
}

Future<PlaylistWithID> getPlaylistFromID(String playlistID) async {
  // given a playlist ID will return that playlist object
  PlaylistWithID retrievedPlaylist;
  await playlists.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          var data = {
            'user': doc['user'],
            'name': doc['name'],
            'songs': List<String>.from(doc['songs']),
            'image': doc['image'],
            'id': doc.id
          };
          if (doc.id == playlistID) {
            retrievedPlaylist = PlaylistWithID.fromMap(data);
          }
        })
      });
  return retrievedPlaylist;
}
