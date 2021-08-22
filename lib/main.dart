import 'package:charge_up/blocs/application_bloc.dart';
import 'package:charge_up/domain/user.dart';
import 'package:charge_up/screens/confirm_register.dart';
import 'package:charge_up/screens/login.dart';
import 'package:charge_up/screens/register.dart';
import 'package:charge_up/util/shared_preference.dart';
import 'package:provider/provider.dart';
import 'screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:charge_up/providers/auth_provider.dart';
import 'package:charge_up/providers/user_provider.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<User> getUserData() => UserPreferences().getUser();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ApplicationBloc())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        title: 'Charge Up',
        home: FutureBuilder(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return Login();
              }
            }
          },
        ),
        routes: {
          '/home': (context) => Home(),
          '/login': (context) => Login(),
          '/register': (context) => Register(),
          '/confirm_register': (context) => ConfirmRegister()
        },
      ),
    );
  }
}
