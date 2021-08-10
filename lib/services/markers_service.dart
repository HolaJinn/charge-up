import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:charge_up/models/charging_station.dart';

class MarkersService {
  List<Marker> getMarkers(List<ChargingStation> chargingStations) {
    List<Marker> markers = [];

    chargingStations.forEach((chargingStation) {
      Marker marker = Marker(
        markerId: MarkerId((chargingStation.id).toString()),
        draggable: false,
        infoWindow: InfoWindow(
            title: chargingStation.name, snippet: chargingStation.description),
        position: LatLng(chargingStation.location.latitude,
            chargingStation.location.longitude),
      );
      markers.add(marker);
    });
    return markers;
  }
}
