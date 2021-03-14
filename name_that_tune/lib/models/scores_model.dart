class ScoreModel {
  String date;
  String game;
  String score;
  String user;

  ScoreModel({this.date, this.game, this.score, this.user});

  factory ScoreModel.fromMap(Map data) {
    return ScoreModel(
      date: data['date'] ?? '',
      game: data['game'] ?? '',
      score: data['score'] ?? '',
      user: data['user'] ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {"date": date, "game": game, "score": score, "user": user};
}
