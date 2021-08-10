import 'package:charge_up/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Filter extends StatefulWidget {
  const Filter({Key? key}) : super(key: key);

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  double _currentMaxDistance = 20;
  double _currentChargingPower = 7;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: primaryColor,
          title: Text(
            'Filter',
            style: TextStyle(
                color: Colors.white, fontSize: 25, letterSpacing: 1.2),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Reset',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Container(
                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Text('Maximum Distance'),
                    Slider(
                      activeColor: primaryColor,
                      inactiveColor: Colors.grey[200],
                      value: _currentMaxDistance,
                      min: 10,
                      max: 300,
                      divisions: 10,
                      label: _currentMaxDistance.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentMaxDistance = value;
                        });
                      },
                    ),
                  ],
                )),
            Container(
                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Text('Charging Power'),
                    Slider(
                      activeColor: primaryColor,
                      inactiveColor: Colors.grey[200],
                      value: _currentChargingPower,
                      min: 3,
                      max: 350,
                      divisions: 6,
                      label: _currentChargingPower.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentChargingPower = value;
                        });
                      },
                    ),
                  ],
                )),
            Container(
                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Text('Connectors'),
                    //Connectors Field goes here but I need the connectors Icons
                  ],
                ))
          ],
        ));
  }
}
