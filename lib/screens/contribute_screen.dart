import 'package:charge_up/blocs/application_bloc.dart';
import 'package:charge_up/models/charging_station.dart';
import 'package:charge_up/models/location.dart' as NewLocation;
import 'package:charge_up/services/charging_stations_service.dart';
import 'package:charge_up/services/geolocator_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class ContributeScreen extends StatefulWidget {
  const ContributeScreen({Key? key}) : super(key: key);

  @override
  _ContributeScreenState createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  late GoogleMapController _googleMapController;
  final geoLocatorService = GeolocatorService();
  final chargingStationsService = ChargingStationsService();
  List<Placemark> placemarks = [];
  List<Marker> addedMarkers = [];

  _addMarker(LatLng tappedPoint) {
    setState(() {
      addedMarkers = [];
      addedMarkers.add(Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () async {
            placemarks = await geoLocatorService.getAddress(tappedPoint);
            await createAlertDialog(context, tappedPoint, placemarks[0])
                .then((chargingStation) {
              final applicationBloc =
                  Provider.of<ApplicationBloc>(context, listen: false);
              final currentUser = applicationBloc.user;
              chargingStationsService
                  .addStation(
                      currentUser.userId, currentUser.token, chargingStation)
                  .then((httpResponse) {
                if (httpResponse.statusCode == 201) {
                  applicationBloc.setChargingStations();
                  toastSuccessMsg('You have successfully added a new station');
                } else {
                  toastErrorMsg('There was an error creating the station');
                }
              });
            });
          }));
    });
  }

  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  void onMapCreated(controller) {
    setState(() {
      _googleMapController = controller;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<ChargingStation> createAlertDialog(
      BuildContext context, LatLng position, Placemark placemark) async {
    int id = position.latitude.toInt();
    String name;
    String description;
    String workingTime;
    bool available;
    NewLocation.Location location = NewLocation.Location(
        city: placemark.street,
        country: placemark.locality,
        latitude: position.latitude,
        longitude: position.longitude);
    List<dynamic> stationPhotos = [];
    return await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _nameController = TextEditingController();
          TextEditingController _descriptionController =
              TextEditingController();
          TextEditingController _workingTimeController =
              TextEditingController();
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Save this station?'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        decoration: InputDecoration(hintText: "Station's Name"),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        decoration: InputDecoration(hintText: "Description"),
                      ),
                      TextFormField(
                        controller: _workingTimeController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        decoration: InputDecoration(hintText: "Working Time"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Is the station available?'),
                          Checkbox(
                              value: isChecked,
                              onChanged: (checked) {
                                setState(() {
                                  isChecked = checked!;
                                });
                              })
                        ],
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                MaterialButton(
                  elevation: 5,
                  child: Text('Submit'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Do something like updating SharedPreferences or User Settings etc.
                      name = _nameController.text;
                      description = _descriptionController.text;
                      workingTime = _workingTimeController.text;
                      available = isChecked;
                      ChargingStation newStation = ChargingStation(
                          id: id,
                          name: name,
                          description: description,
                          available: available,
                          location: location,
                          workingTime: workingTime,
                          stationPhotos: stationPhotos);

                      Navigator.of(context).pop(newStation);
                    }
                  },
                )
              ],
            );
          });
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

      chargingStations.forEach((chargingStation) {
        Marker marker = Marker(
          markerId: MarkerId((chargingStation.id).toString()),
          draggable: false,
          infoWindow: InfoWindow(
              title: chargingStation.name,
              snippet: chargingStation.description),
          position: LatLng(chargingStation.location.latitude,
              chargingStation.location.longitude),
        );
        markers.add(marker);
      });
      return markers;
    }

    markers.addAll(getMarkers(chargingStations));
    markers.addAll(addedMarkers);

    // **Bring This back later**
    // final _initialCameraPosition = CameraPosition(
    //     target: LatLng(applicationBloc.currentLocation.latitude,
    //         applicationBloc.currentLocation.longitude),
    //     zoom: 14);

    //This is for testing
    //I'm choosing Tunis as a initial position because the emulator location is in the US
    // Tunis LatLng : LatLng(36.806389, 10.181667)
    //Testing : LatLng(20.15,18.26)
    final _initialCameraPosition =
        CameraPosition(target: LatLng(36.806389, 10.181667), zoom: 14);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text(
          'Add Station ',
          style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 1),
        ),
      ),
      body: Stack(
        children: [
          Container(
            child: GoogleMap(
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: onMapCreated,
              markers: Set.from(markers),
              onLongPress: _addMarker,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: 'Near me btn',
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                onPressed: () => _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(_initialCameraPosition),
                ),
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                child: const Icon(
                  Icons.near_me,
                  color: Colors.black54,
                ),
                elevation: 3,
              ),
            ),
          )
        ],
      ),
    );
  }

  void toastErrorMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red.shade300,
      content: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_outlined,
            color: Colors.white,
          ),
          Text(msg),
        ],
      ),
      duration: Duration(seconds: 5),
    ));
  }

  void toastSuccessMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.greenAccent.shade700,
      content: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          Text(msg, style: TextStyle(color: Colors.white)),
        ],
      ),
      duration: Duration(seconds: 5),
    ));
  }
}
