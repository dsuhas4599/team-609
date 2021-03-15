class GameModel {
  String user;
  List<String> rounds;

  GameModel({this.rounds, this.user});

  factory GameModel.fromMap(Map data) {
    return GameModel(
      user: data['user'] ?? '',
      rounds: data['rounds'] ?? '',
    );
  }

  Map<String, dynamic> toJson() =>
      {"user": user, "rounds": rounds};
}
