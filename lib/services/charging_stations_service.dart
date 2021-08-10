import 'package:charge_up/models/charging_station.dart';
import 'package:charge_up/models/evaluation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ChargingStationsService {
  Future<List<ChargingStation>> getStations() async {
    final url = Uri.parse(
        ('https://charge-up1.herokuapp.com/api/v1/stations?_limit=10&_order=asc&_page=0&_sort=id'));
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['content'] as List;
    return jsonResults
        .map((station) => ChargingStation.fromJson(station))
        .toList();
  }

  Future<http.Response> addStation(
      int userId, ChargingStation chargingStation) async {
    var url = Uri.parse(
        'https://charge-up1.herokuapp.com/api/v1/users/$userId/stations');
    final headers = {"Content-type": "application/json"};
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
        'https://charge-up1.herokuapp.com/api/v1/stations/$chargingStationId/rating');
    var response = await http.get(url);
    return response.body;
  }

  Future<List<Evaluation>> getStationEvaluations(int chargingStationId) async {
    var url = Uri.parse(
        'https://charge-up1.herokuapp.com/api/v1/stations/$chargingStationId/evaluations?_limit=10&_page=0');
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['content'] as List;
    return jsonResults
        .map((evaluation) => Evaluation.fromJson(evaluation))
        .toList();
  }
}
