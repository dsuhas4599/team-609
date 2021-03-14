class SongModel {
  String date;
  String name;
  String artist;
  String videoID;

  SongModel({this.date, this.name, this.artist, this.videoID});

  factory SongModel.fromMap(Map data) {
    return SongModel(
      date: data['date'] ?? '',
      name: data['name'] ?? '',
      artist: data['artist'] ?? '',
      videoID: data['videoID'] ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {"date": date, "name": name, "artist": artist, "videoID": videoID};
}
