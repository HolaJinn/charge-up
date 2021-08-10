import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:charge_up/models/place_search.dart';

class PlacesService {
  final key = 'AIzaSyDn3Ys-s5V4XVgnlkuIe92firgW-D5mAx4';
  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    print('test from service');
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }
}
