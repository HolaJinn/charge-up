import 'package:charge_up/blocs/application_bloc.dart';
import 'package:provider/provider.dart';

import 'screens/home/home.dart';
import 'package:flutter/material.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApplicationBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        title: 'Charge Up',
        home: Home(),
      ),
    );
  }
}
