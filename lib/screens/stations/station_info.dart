import 'package:charge_up/blocs/application_bloc.dart';
import 'package:charge_up/domain/user.dart';
import 'package:charge_up/models/charger.dart';
import 'package:charge_up/models/charging_station.dart';
import 'package:charge_up/services/chargers_service.dart';
import 'package:charge_up/services/charging_stations_service.dart';
import 'package:charge_up/services/geolocator_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:rating_dialog/rating_dialog.dart';

import '../../constants.dart';

//All this section is HARD CODED for now it must be revisited
//after providing information station from API

class StationInfo extends StatefulWidget {
  final ChargingStation chargingStation;
  final User user;
  const StationInfo(
      {Key? key, required this.chargingStation, required this.user})
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
      var ratingStars = double.parse(value.substring(17, 20));
      var nbUsers = int.parse(value.substring(41, 42));
      widget.chargingStation.ratingStars = ratingStars;
      widget.chargingStation.nbrOfUsersRating = nbUsers;
    });

    await chargersService
        .getChargers(widget.chargingStation.id)
        .then((charger) {
      widget.chargingStation.chargers.addAll(charger);
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

  void _showRatingDialog() {
    final _dialog = RatingDialog(
      title: 'Rating Dialog',
      message:
          'Tap a star to set your rating. Add more description here if you want.',
      image: const FlutterLogo(
        size: 100,
      ),
      submitButton: 'Submit',
      onCancelled: () => print('Canceled'),
      onSubmitted: (response) {
        print('Rating: ${response.rating}, Comment: ${response.comment}');
        chargingStationsService.addStationEvalutation(widget.user.userId,
            widget.user.token, widget.chargingStation.id, response);
      },
    );

    showDialog(context: context, builder: (context) => _dialog);
  }

  void _showUpdateDeleteChargerDialog(BuildContext context, Charger charger) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Choose your action'),
              content: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      child: Text('Update'),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      onPressed: () {
                        _showUpdateChargerDialog(context, charger);
                      },
                    ),
                    ElevatedButton(
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () {
                        chargersService
                            .deleteCharger(
                                widget.user.userId,
                                widget.user.token,
                                widget.chargingStation.id,
                                charger.id)
                            .then((response) {
                          Navigator.of(context).pop();
                          if (response.statusCode == 200) {
                            toastSuccessMsg('Charger Deleted');
                          } else {
                            toastErrorMsg('Could not delete this charger');
                          }
                        });
                        setState(() {
                          userFuture = _getStationCompleteInfo();
                        });
                      },
                    )
                  ],
                ),
              ));
        });
  }

  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  void _showUpdateChargerDialog(BuildContext context, Charger charger) {
    showDialog(
        context: context,
        builder: (context) {
          int chargerId = charger.id;
          String description = charger.description;
          String type = charger.type;
          double price = charger.chargingPrice;
          double power = charger.power;
          bool available;
          bool isChecked = charger.available;
          print(charger.type);
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Update this Charger'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey2,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: charger.type,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        onSaved: (value) => type = value!,
                        decoration: InputDecoration(hintText: "Charger's Type"),
                      ),
                      TextFormField(
                        initialValue: (charger.power).toString(),
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        onSaved: (value) => power = double.parse(value!),
                        decoration:
                            InputDecoration(hintText: "Charger's Power"),
                      ),
                      TextFormField(
                        initialValue: (charger.chargingPrice).toString(),
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        onSaved: (value) => price = double.parse(value!),
                        decoration:
                            InputDecoration(hintText: "Charger's Price"),
                      ),
                      TextFormField(
                        initialValue: charger.description,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        onSaved: (value) => description = value!,
                        decoration:
                            InputDecoration(hintText: "Charger's Description"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Is the charger available?'),
                          Checkbox(
                            value: isChecked,
                            onChanged: (checked) {
                              setState(() {
                                isChecked = checked!;
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                MaterialButton(
                    elevation: 5,
                    textColor: Colors.white,
                    color: primaryColor,
                    child: Text('Submit'),
                    onPressed: () {
                      if (_formKey2.currentState!.validate()) {
                        available = isChecked;
                        _formKey2.currentState!.save();
                        Charger updatedCharger = new Charger(
                            id: chargerId,
                            available: available,
                            type: type,
                            description: description,
                            chargingPrice: price,
                            power: power);
                        chargersService
                            .updateCharger(
                                widget.user.userId,
                                widget.user.token,
                                widget.chargingStation.id,
                                updatedCharger)
                            .then((response) {
                          print(response.statusCode);
                        });
                        Navigator.of(context).pop();
                      }
                    })
              ],
            );
          });
        });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void _showCreateChargerDialog(BuildContext context) {
    String description;
    String type;
    double price;
    double power;
    bool available;
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController _priceController = TextEditingController();
          TextEditingController _powerController = TextEditingController();
          TextEditingController _typeController = TextEditingController();
          TextEditingController _descriptionController =
              TextEditingController();
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Add a New Charger'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _typeController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        decoration: InputDecoration(hintText: "Charger's Type"),
                      ),
                      TextFormField(
                        controller: _powerController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        decoration:
                            InputDecoration(hintText: "Charger's Power"),
                      ),
                      TextFormField(
                        controller: _priceController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        decoration:
                            InputDecoration(hintText: "Charger's Price"),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : 'Invalid Field';
                        },
                        decoration:
                            InputDecoration(hintText: "Charger's Description"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Is the charger available?'),
                          Checkbox(
                            value: isChecked,
                            onChanged: (checked) {
                              setState(() {
                                isChecked = checked!;
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                MaterialButton(
                    elevation: 5,
                    textColor: Colors.white,
                    color: primaryColor,
                    child: Text('Submit'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        description = _descriptionController.text;
                        type = _typeController.text;
                        price = double.parse(_priceController.text);
                        power = double.parse(_powerController.text);
                        available = isChecked;
                        Charger newCharger = new Charger(
                            id: widget.chargingStation.chargers.length + 1,
                            available: available,
                            type: type,
                            description: description,
                            chargingPrice: price,
                            power: power);
                        chargersService
                            .addCharger(widget.user.userId, widget.user.token,
                                widget.chargingStation.id, newCharger)
                            .then((response) {
                          if (response.statusCode == 201) {
                            chargersService
                                .getChargers(widget.chargingStation.id)
                                .then((chargers) {
                              widget.chargingStation.chargers.addAll(chargers);
                            });
                            toastSuccessMsg('New Charger has been added');
                          } else {
                            toastErrorMsg(
                                'An error has occured: ${response.body}');
                          }
                        });
                        Navigator.of(context).pop();
                      }
                    })
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final chargingStation = widget.chargingStation;
    final geoLocatorService = GeolocatorService();
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    final currentLocation = applicationBloc.currentLocation;

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
                                child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(),
                                    itemCount: chargingStation.chargers.length,
                                    itemBuilder: (context, index) {
                                      if (chargingStation
                                              .chargers[index].available ==
                                          true)
                                        return GestureDetector(
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.charging_station,
                                              size: 50,
                                            ),
                                            title: Text(
                                                'Type : ${chargingStation.chargers[index].type}'),
                                            subtitle: Text(
                                                'Power : ${chargingStation.chargers[index].power} kW'),
                                            trailing: Text(
                                                '${chargingStation.chargers[index].chargingPrice} \$'),
                                          ),
                                          onLongPress: () {
                                            print('Hello from Item');
                                            _showUpdateDeleteChargerDialog(
                                                context,
                                                chargingStation
                                                    .chargers[index]);
                                          },
                                        );
                                      return Container();
                                    }),
                              ),
                            if (user.role.contains('STATION_OWNER'))
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
                                  child: Text('Add Charger'),
                                  onPressed: () {
                                    _showCreateChargerDialog(context);
                                  },
                                ),
                              )
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
                        child: Stack(
                          children: [
                            Center(
                                child: ListView.builder(
                                    itemCount:
                                        chargingStation.evaluations.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        leading:
                                            Image.network('${user.photoUri}'),
                                        title: Text(
                                            '${chargingStation.evaluations[index].comment}'),
                                        subtitle: Text(
                                            '${chargingStation.evaluations[index].user.firstName} ${chargingStation.evaluations[index].user.lastName} / ${chargingStation.evaluations[index].date} \n ${chargingStation.evaluations[index].starsNumber} Stars'),
                                        isThreeLine: true,
                                      );
                                    })),
                            Container(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                child: Text('Rate this Station'),
                                onPressed: _showRatingDialog,
                              ),
                            ),
                          ],
                        ),
                      )

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
