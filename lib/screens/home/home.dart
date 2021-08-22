import 'package:charge_up/blocs/application_bloc.dart';
import 'package:charge_up/constants.dart';
import 'package:charge_up/screens/contribute_screen.dart';
import 'package:charge_up/screens/explore_screen.dart';
import 'package:charge_up/screens/profile_screen.dart';
import 'package:charge_up/util/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static const List<Widget> _children = <Widget>[
    ExploreScreen(),
    ProfileScreen(),
    ContributeScreen()
  ];
  late Future futureUser;

  getCurrentUser() async {
    return await UserPreferences().getUser();
  }

  @override
  void initState() {
    super.initState();
    futureUser = getCurrentUser();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else {
              return Scaffold(
                body: Center(
                  child: _children.elementAt(_selectedIndex),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  selectedItemColor: primaryColor,
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.explore), label: 'Explore'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person), label: 'Profile'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.add), label: 'Contribute'),
                  ],
                ),
              );
            }
          }
        });
  }
}
