// Functions for getting data from firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_starter/models/models.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference playlists = FirebaseFirestore.instance.collection('playlists');
CollectionReference songs = FirebaseFirestore.instance.collection('songs');

// Song functions
Future getAllSongs() async { // returns all songs in a list of song models
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

Future getAllSongNames() async { // returns a list of all song names
  List<String> songNames = [];
  await songs.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          songNames.add(doc['name']);
        })
      });
  return songNames;
}

Future createAnswerChoices(String videoID) async { // returns 4 answer choices with the first one being the answer
  List<SongModel> allSongs = await getAllSongs();
  List<String> answerChoices = [];
  String correctChoice = allSongs.firstWhere((song) => song.videoID == videoID).name;
  answerChoices.add(correctChoice);
  allSongs.removeWhere((song) => song.videoID == videoID);
  allSongs.shuffle();
  allSongs.take(3).forEach((song) {answerChoices.add(song.name);});
  return answerChoices;
}

Future createAnswerChoicesFromPlaylist(String videoID, String playlist) async { // returns 4 answer choices from a given playlist
  List<SongModel> playlistSongs = await playlistToSongs(playlist);
  List<String> answerChoices = [];
}

Future playlistToSongs(String playlist) async { // given a playlist object, will retrieve the list of songs from document ID
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

// Playlist functions
Future getAllPlaylists() async { // returns a list of all playlists in firestore
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

Future getSpecificPlaylist(String playlistName) async { // given a playlist name will return that playlist object
  List<PlaylistModel> allPlaylists = await getAllPlaylists();
  PlaylistModel currentPlaylist = allPlaylists.firstWhere((playlist) => playlist.name == playlistName);
  return currentPlaylist;
}