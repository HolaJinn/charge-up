import 'dart:io';

import 'package:charge_up/domain/user.dart';
import 'package:charge_up/models/charging_station.dart';
import 'package:charge_up/models/evaluation.dart';
import 'package:charge_up/util/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:rating_dialog/rating_dialog.dart';

class ChargingStationsService {
  Future<List<ChargingStation>> getStations() async {
    final url = Uri.parse(
        ('https://charge-up2.herokuapp.com/api/v1/stations?_limit=10&_order=asc&_page=0'));
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    print(response.body);
    var jsonResults = json['content'] as List;
    return jsonResults
        .map((station) => ChargingStation.fromJson(station))
        .toList();
  }

  Future<http.Response> addStation(
      int userId, String token, ChargingStation chargingStation) async {
    var url = Uri.parse(
        'https://charge-up2.herokuapp.com/api/v1/users/$userId/stations');
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token"
    };
    //TODO : Change the json variable
    Map data = {
      'available': chargingStation.available,
      'description': chargingStation.description,
      'location': {
        'city': chargingStation.location.city,
        'country': chargingStation.location.country,
        'latitudeCoordinates': chargingStation.location.latitude,
        'longitudeCoordinates': chargingStation.location.longitude
      },
      'name': chargingStation.name,
      'workingTime': chargingStation.workingTime
    };
    var body = convert.jsonEncode(data);
    var response = await http.post(url, headers: headers, body: body);
    return response;
  }

  Future<String> getStationRating(int chargingStationId) async {
    var url = Uri.parse(
        'https://charge-up2.herokuapp.com/api/v1/stations/$chargingStationId/rating');
    var response = await http.get(url);
    return response.body;
  }

  Future<List<Evaluation>> getStationEvaluations(int chargingStationId) async {
    var url = Uri.parse(
        'https://charge-up2.herokuapp.com/api/v1/stations/$chargingStationId/evaluations?_limit=10&_page=0');
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['content'] as List;
    return jsonResults
        .map((evaluation) => Evaluation.fromJson(evaluation))
        .toList();
  }

  Future<http.Response> addStationEvalutation(int userId, String token,
      int chargingStationId, RatingDialogResponse evaluation) async {
    print('Test1');
    var url = Uri.parse(
        'https://charge-up2.herokuapp.com/api/v1/users/$userId/station-evaluations/$chargingStationId');
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token"
    };
    Map data = {
      'comment': evaluation.comment,
      'starsNumber': (evaluation.rating).toString()
    };
    print('test2');
    var body = convert.jsonEncode(data);
    print('test3');

    var response = await http.post(url, headers: headers, body: body);
    print(response.body);
    print(response.statusCode);
    print('test4');

    return response;
  }
}
