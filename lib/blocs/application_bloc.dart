import 'package:charge_up/domain/user.dart';
import 'package:charge_up/models/charging_station.dart';
import 'package:charge_up/models/place_search.dart';
import 'package:charge_up/services/charging_stations_service.dart';
import 'package:charge_up/services/geolocator_service.dart';
import 'package:charge_up/services/places_service.dart';
import 'package:charge_up/util/shared_preference.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class ApplicationBloc with ChangeNotifier {
  final geolocatorService = GeolocatorService();
  final placesService = PlacesService();
  final chargingStationsService = ChargingStationsService();

  //variables
  late Position currentLocation;
  List<PlaceSearch> searchResults = [];
  List<ChargingStation> chargingStations = [];
  late User user;

  ApplicationBloc() {
    getCurrentUser();
    setCurrentLocation();
    setChargingStations();
  }

  getCurrentUser() async {
    user = await UserPreferences().getUser();
    notifyListeners();
  }

  ChargingStation findChargingStation(
      List<ChargingStation> chargingStations, int id) {
    final index = chargingStations.indexWhere((element) => element.id == id);
    return chargingStations[index];
  }

  setChargingStations() async {
    chargingStations = await chargingStationsService.getStations();
    notifyListeners();
  }

  setStationRating(ChargingStation chargingStation) async {
    chargingStationsService.getStationRating(chargingStation.id).then((value) {
      var ratingStars = double.parse(value.substring(16, 19));
      var nbUsers = int.parse(value.substring(24, 25));
      chargingStation.ratingStars = ratingStars;
      chargingStation.nbrOfUsersRating = nbUsers;
    });
    notifyListeners();
  }

  setCurrentLocation() async {
    currentLocation = await geolocatorService.getCurrentLocation();
    notifyListeners();
  }

  searchPlaces(String searhcTerm) async {
    searchResults = await placesService.getAutocomplete(searhcTerm);
    notifyListeners();
  }
}
