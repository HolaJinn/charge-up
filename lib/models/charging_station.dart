import 'package:charge_up/models/charger.dart';
import 'package:charge_up/models/evaluation.dart';
import 'package:charge_up/models/location.dart';

class ChargingStation {
  final bool available;
  final String description;
  final int id;
  final Location location;
  final String name;
  final List<dynamic> stationPhotos;
  final String workingTime;
  double ratingStars = 0.0;
  int nbrOfUsersRating = 0;
  List<Charger> chargers = [];
  List<Evaluation> evaluations = [];

  ChargingStation(
      {required this.id,
      required this.name,
      required this.description,
      required this.available,
      required this.location,
      required this.workingTime,
      required this.stationPhotos});

  ChargingStation.fromJson(Map<dynamic, dynamic> parsedJson)
      : id = parsedJson['id'],
        name = parsedJson['name'],
        description = parsedJson['description'],
        available = parsedJson['available'],
        location = Location.fromJson(parsedJson['location']),
        workingTime = parsedJson['workingTime'],
        stationPhotos = parsedJson['stationPhotos'];
}
