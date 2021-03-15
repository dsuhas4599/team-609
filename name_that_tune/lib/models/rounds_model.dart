class RoundModel {
  String guesses;
  String song;
  String time;
  String user;

  RoundModel({this.guesses, this.song, this.time, this.user});

  factory RoundModel.fromMap(Map data) {
    return RoundModel(
      guesses: data['guesses'] ?? '',
      song: data['song'] ?? '',
      time: data['time'] ?? '',
      user: data['user'] ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {"guesses": guesses, "song": song, "time": time, "user": user};
}
