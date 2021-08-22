import 'package:charge_up/blocs/application_bloc.dart';
import 'package:charge_up/constants.dart';
import 'package:charge_up/domain/user.dart';
import 'package:charge_up/util/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    final user = applicationBloc.user;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Profile'),
          backgroundColor: primaryColor,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(100, 10, 0, 20),
                  width: 200,
                  height: 200,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage('${user.photoUri}'),
                        fit: BoxFit.fill),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(100, 0, 0, 10),
                  child: Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(100, 0, 0, 10),
                  child: Text(
                    '${user.login}',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(100, 0, 0, 10),
                    child: ElevatedButton(
                      child: Text(
                        'Edit Your Phone Number',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {},
                      style:
                          ElevatedButton.styleFrom(primary: Colors.green[600]),
                    )),
              ],
            ),
            Container(
              child: FloatingActionButton(
                child: Icon(Icons.logout),
                onPressed: () {
                  UserPreferences().removeUser();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            )
          ],
        ));
  }
}
