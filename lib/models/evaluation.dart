import 'package:charge_up/models/user.dart';

class Evaluation {
  final String comment;
  final String date;
  final User user;
  final int starsNumber;

  Evaluation(
      {required this.comment,
      required this.date,
      required this.user,
      required this.starsNumber});

  Evaluation.fromJson(Map<dynamic, dynamic> parsedJson)
      : comment = parsedJson['comment'],
        date = parsedJson['date'],
        user = User.fromJson(parsedJson['evaluatedBy']),
        starsNumber = parsedJson['starsNumber'];
}
