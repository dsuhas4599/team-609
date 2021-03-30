class PlaylistModel {
  String user;
  String name;
  List<String> songs;

  PlaylistModel({this.user, this.name, this.songs});

  factory PlaylistModel.fromMap(Map data) {
    return PlaylistModel(
      user: data['user'] ?? '',
      name: data['name'] ?? '',
      songs: data['songs'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {"user": user, "name": name, "songs": songs};
}
