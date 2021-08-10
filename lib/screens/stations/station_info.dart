import 'package:charge_up/blocs/application_bloc.dart';
import 'package:charge_up/models/charging_station.dart';
import 'package:charge_up/services/chargers_service.dart';
import 'package:charge_up/services/charging_stations_service.dart';
import 'package:charge_up/services/geolocator_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import '../../constants.dart';

//All this section is HARD CODED for now it must be revisited
//after providing information station from API

class StationInfo extends StatefulWidget {
  final ChargingStation chargingStation;
  const StationInfo({Key? key, required this.chargingStation})
      : super(key: key);

  @override
  _StationInfoState createState() => _StationInfoState();
}

class _StationInfoState extends State<StationInfo> {
  final chargingStationsService = ChargingStationsService();
  final chargersService = ChargersService();
  late Future userFuture;

  _getStationCompleteInfo() async {
    await chargingStationsService
        .getStationRating(widget.chargingStation.id)
        .then((value) {
      var ratingStars = double.parse(value.substring(16, 19));
      var nbUsers = int.parse(value.substring(24, 25));
      widget.chargingStation.ratingStars = ratingStars;
      widget.chargingStation.nbrOfUsersRating = nbUsers;
    });

    await chargersService
        .getChargers(widget.chargingStation.id)
        .then((charger) {
      widget.chargingStation.chargers.addAll(charger);
      print(widget.chargingStation.chargers.length);
    });

    await chargingStationsService
        .getStationEvaluations(widget.chargingStation.id)
        .then((evaluation) {
      widget.chargingStation.evaluations.addAll(evaluation);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.chargingStation.chargers = [];
    widget.chargingStation.evaluations = [];
    userFuture = _getStationCompleteInfo();
  }

  @override
  Widget build(BuildContext context) {
    final chargingStation = widget.chargingStation;
    final geoLocatorService = GeolocatorService();
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    final currentLocation = applicationBloc.currentLocation;
    //final chargingStationsService = ChargingStationsService();
    // chargingStationsService.getStationRating(chargingStation.id).then((value) {
    //   var ratingStars = double.parse(value.substring(16, 19));
    //   var nbUsers = int.parse(value.substring(24, 25));
    //   chargingStation.ratingStars = ratingStars;
    //   chargingStation.nbrOfUsersRating = nbUsers;
    // });

    //Could use Tunis coordinates  : LatLng(36.806389, 10.181667)
    final distance = geoLocatorService.getDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        chargingStation.location.latitude,
        chargingStation.location.longitude);
    return Container(
      child: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Scaffold(
              body: LiquidLinearProgressIndicator(
                value: 0.25, // Defaults to 0.5.
                valueColor: AlwaysStoppedAnimation(Colors
                    .pink), // Defaults to the current Theme's accentColor.
                backgroundColor: Colors
                    .white, // Defaults to the current Theme's backgroundColor.
                borderColor: Colors.red,
                borderWidth: 1.0,
                borderRadius: 12.0,
                direction: Axis
                    .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                center: Text(
                  "Loading...",
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ));
          } else {
            if (snapshot.hasError)
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            else
              return DefaultTabController(
                initialIndex: 0,
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    backgroundColor: primaryColor,
                    title: const Text(
                      'Station Info',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    bottom: const TabBar(
                      tabs: <Widget>[
                        Tab(
                          icon: Icon(Icons.info),
                        ),
                        Tab(
                          icon: Icon(Icons.camera_alt),
                        ),
                        Tab(
                          icon: Icon(Icons.comment),
                        ),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: <Widget>[
                      //Info Tab Starts here
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chargingStation.name,
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${chargingStation.location.city}, ${chargingStation.location.country}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${chargingStation.workingTime}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 18),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Rating: ',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                ),
                                RatingBarIndicator(
                                  rating: chargingStation.ratingStars,
                                  itemBuilder: (context, index) =>
                                      Icon(Icons.star, color: primaryColor),
                                  itemCount: 5,
                                  itemSize: 20,
                                  direction: Axis.horizontal,
                                ),
                                VerticalDivider(
                                  color: Colors.black,
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 0,
                                  width: 20,
                                ),
                                Text(
                                    '${chargingStation.nbrOfUsersRating} Users')
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Distance : ${(distance / 1000).round()} KM'),
                            SizedBox(
                              height: 20,
                            ),
                            if (chargingStation.chargers.isNotEmpty)
                              Expanded(
                                child: ListView.builder(
                                    itemCount: chargingStation.chargers.length,
                                    itemBuilder: (context, index) {
                                      if (chargingStation
                                              .chargers[index].available ==
                                          true)
                                        return ListTile(
                                          leading: Icon(Icons.charging_station),
                                          title: Text(
                                              'Type : ${chargingStation.chargers[index].type}'),
                                          subtitle: Text(
                                              'Power : ${chargingStation.chargers[index].power} kW'),
                                          trailing: Text(
                                              '${chargingStation.chargers[index].chargingPrice} \$'),
                                        );
                                      return Container();
                                    }),
                              ),
                          ],
                        ),
                      ),
                      //Info Tab Ends here

                      //Photos Tab Starts here
                      if (chargingStation.stationPhotos.isNotEmpty)
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 5),
                              itemBuilder: (context, index) {
                                return Image.network(
                                    'https://picsum.photos/250?image=9');
                              }),
                        )),

                      if (chargingStation.stationPhotos.isEmpty)
                        Center(
                            child: Text('There are no images of this station')),
                      //Photos Tab Ends here

                      //Comments Tab Starts here
                      Center(
                          child: ListView.builder(
                              itemCount: chargingStation.evaluations.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(
                                    Icons.person,
                                    size: 50,
                                  ),
                                  title: Text(
                                      '${chargingStation.evaluations[index].comment}'),
                                  subtitle: Text(
                                      '${chargingStation.evaluations[index].user.firstName} ${chargingStation.evaluations[index].user.lastName} / ${chargingStation.evaluations[index].date} \n ${chargingStation.evaluations[index].starsNumber} Stars'),
                                  isThreeLine: true,
                                );
                              })),
                      //Comments Tab Ends here
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
