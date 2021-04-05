class PlaylistModel {
  String user;
  String name;
  List<String> songs;
  String image;

  PlaylistModel({this.user, this.name, this.songs, this.image});

  factory PlaylistModel.fromMap(Map data) {
    return PlaylistModel(
      user: data['user'] ?? '',
      name: data['name'] ?? '',
      songs: data['songs'] ?? '',
      image: data['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {"user": user, "name": name, "songs": songs, "image": image};
}
