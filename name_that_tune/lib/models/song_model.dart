class SongModel {
  int id;
  String name;
  String artist;
  String api;

  SongModel({this.id, this.name, this.artist, this.api});

  factory SongModel.fromMap(Map data) {
    return SongModel(
      id: data['id'],
      name: data['name'] ?? '',
      artist: data['artist'] ?? '',
      api: data['api'] ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {"id": id, "name": name, "artist": artist, "api": api};
}
