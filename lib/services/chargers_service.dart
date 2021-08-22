import 'package:charge_up/models/charger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ChargersService {
  getChargers(int chargingStationId) async {
    var url = Uri.parse(
        'https://charge-up2.herokuapp.com/api/v1/stations/$chargingStationId/chargers');
    var response = await http.get(url);
    var jsonResult = convert.jsonDecode(response.body) as List;
    //Should have a value here?
    //This should be removed
    print(jsonResult);
    return jsonResult.map((charger) => Charger.fromJson(charger)).toList();
  }

  Future<http.Response> addCharger(int userId, String token,
      int chargingStationId, Charger newCharger) async {
    var url = Uri.parse(
        'https://charge-up2.herokuapp.com/api/v1/users/$userId/stations/$chargingStationId/chargers');
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token"
    };
    Map data = {
      'available': newCharger.available,
      'chargingPrice': newCharger.chargingPrice,
      'description': newCharger.description,
      'power': newCharger.power,
      'type': newCharger.type
    };
    var body = convert.jsonEncode(data);
    var response = await http.post(url, headers: headers, body: body);
    return response;
  }

  Future<http.Response> deleteCharger(
      int userId, String token, int chargingStationId, int chargerId) async {
    var url = Uri.parse(
        'https://charge-up2.herokuapp.com/api/v1/users/$userId/stations/$chargingStationId/chargers/$chargerId');
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token"
    };
    var response = await http.delete(url, headers: headers);
    print(response.body);
    print(response.statusCode);
    return response;
  }

  Future<http.Response> updateCharger(int userId, String token,
      int chargingStationId, Charger updatedCharger) async {
    var url = Uri.parse(
        'https://charge-up2.herokuapp.com/api/v1/users/$userId/stations/$chargingStationId/chargers/${updatedCharger.id}');
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token"
    };
    Map data = {
      'available': updatedCharger.available,
      'chargingPrice': updatedCharger.chargingPrice,
      'description': updatedCharger.description,
      'power': updatedCharger.power,
      'type': updatedCharger.type
    };
    var body = convert.jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: body);
    print(response.body);
    print(response.statusCode);
    return response;
  }
}
