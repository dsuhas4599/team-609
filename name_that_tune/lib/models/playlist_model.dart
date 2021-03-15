class PlaylistModel {
  int id;
  String name;
  List<String> songs;

  PlaylistModel({this.id, this.name, this.songs});

  factory PlaylistModel.fromMap(Map data) {
    return PlaylistModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      songs: data['songs'] ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {"id": id, "name": name, "songs": songs};
}
