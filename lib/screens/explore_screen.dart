import 'dart:collection';
import 'package:charge_up/blocs/application_bloc.dart';
import 'package:charge_up/constants.dart';
import 'package:charge_up/models/charging_station.dart';
import 'package:charge_up/screens/filter/filter.dart';
import 'package:charge_up/screens/stations/station_info.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:geocoding/geocoding.dart';

//Bring this back later for the sliding up panel
//import 'package:sliding_up_panel/sliding_up_panel.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late GoogleMapController _googleMapController;
  String searchAddress = '';

  searchAndNavigate() {
    print('test');
    locationFromAddress(searchAddress).then((result) {
      _googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(result[0].latitude, result[0].longitude),
        zoom: 10,
      )));
    });
  }

  //Panel Controller is for the sliding panel
  //PanelController _pc = new PanelController();

  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  void onMapCreated(controller) {
    setState(() {
      _googleMapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    var chargingStations = applicationBloc.chargingStations;

    //The first value in the markers list is the current position marker
    //That position should be replaced with currentPosition variable from the applicationBloc
    //I'm using a hard coded position now for a testing reasons
    List<Marker> markers = [
      Marker(
          markerId: MarkerId('100'),
          draggable: false,
          infoWindow: InfoWindow(title: 'This is your current position'),
          position: LatLng(36.806389, 10.181667),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta))
    ];

    List<Marker> getMarkers(List<ChargingStation> chargingStations) {
      List<Marker> markers = [];

      chargingStations.forEach((chargingStation) async {
        final markerIdValue = chargingStation.id;
        Marker marker = Marker(
            markerId: MarkerId((chargingStation.id).toString()),
            draggable: false,
            infoWindow: InfoWindow(
                title: chargingStation.name,
                snippet: chargingStation.description),
            position: LatLng(chargingStation.location.latitude,
                chargingStation.location.longitude),
            onTap: () {
              ChargingStation chargingStation = applicationBloc
                  .findChargingStation(chargingStations, markerIdValue);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StationInfo(
                            chargingStation: chargingStation,
                          )));
            });
        markers.add(marker);
      });
      return markers;
    }

    // **Bring This back later**
    // final _initialCameraPosition = CameraPosition(
    //     target: LatLng(applicationBloc.currentLocation.latitude,
    //         applicationBloc.currentLocation.longitude),
    //     zoom: 14);

    //This is for testing
    //I'm choosing Tunis as a initial position because the emulator location is in the US
    // Tunis LatLng : LatLng(36.806389, 10.181667)
    final _initialCameraPosition =
        CameraPosition(target: LatLng(36.806389, 10.181667), zoom: 14);
    //markers = getMarkers(chargingStations);
    markers.addAll(getMarkers(chargingStations));
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Container(
                child: GoogleMap(
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: onMapCreated,
                  markers: Set<Marker>.of(markers),
                ),
              ),
              if (applicationBloc.searchResults.length != 0)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      backgroundBlendMode: BlendMode.darken),
                ),
              Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: applicationBloc.searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          applicationBloc.searchResults[index].description,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  )),
              Container(
                margin: EdgeInsets.all(20),
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text('Captions',
                              style: TextStyle(
                                  color: Colors.white, letterSpacing: 1.2)),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.all(20),
                              backgroundColor: primaryColor.withOpacity(0.77),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18))),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            FloatingActionButton(
                              heroTag: 'favorite btn',
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey,
                              onPressed: () {},
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(2)),
                              child: const Icon(Icons.favorite,
                                  color: primaryColor),
                              elevation: 3,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            FloatingActionButton(
                              heroTag: 'Near me btn',
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey,
                              onPressed: () =>
                                  _googleMapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    _initialCameraPosition),
                              ),
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(2)),
                              child: const Icon(
                                Icons.near_me,
                                color: Colors.black54,
                              ),
                              elevation: 3,
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 30,
            right: 15,
            left: 15,
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      searchAndNavigate();
                    },
                  ),
                  Expanded(
                    child: TextField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                            hintText: "Enter Location"),
                        onChanged: (value) =>
                            applicationBloc.searchPlaces(value)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        elevation: 0),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Filter()),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          color: primaryColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            'Filter',
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          //TO ADD SLIDING PANEL FOR STATION INFO LATER
          // SlidingUpPanel(
          //   controller: _pc,
          //   panel: Center(
          //     child: Text("This is the sliding Widget"),
          //   ),
          //   body: Center(
          //     child: Text("This is the Widget behind the sliding panel"),
          //   ),
          // )
        ],
      ),
    );
  }
}
