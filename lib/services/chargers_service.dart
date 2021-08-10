import 'package:charge_up/models/charger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ChargersService {
  getChargers(int chargingStationId) async {
    var url = Uri.parse(
        'https://charge-up1.herokuapp.com/api/v1/stations/$chargingStationId/chargers');
    var response = await http.get(url);
    var jsonResult = convert.jsonDecode(response.body) as List;
    //Should have a value here?
    //This should be removed
    print(jsonResult);
    return jsonResult.map((charger) => Charger.fromJson(charger)).toList();
  }
}
