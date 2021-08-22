import 'dart:io';

import 'package:charge_up/constants.dart';
import 'package:charge_up/providers/auth_provider.dart';
import 'package:charge_up/util/widgets.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmRegister extends StatefulWidget {
  @override
  _ConfirmRegisterState createState() => _ConfirmRegisterState();
}

class _ConfirmRegisterState extends State<ConfirmRegister> {
  final _formKey = new GlobalKey<FormState>();
  late Future futureLoging;

  String _verifCode = '';
  String _login = '';
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

  @override
  // ignore: must_call_super
  void initState() {
    futureLoging = getLogin();
  }

  getLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _login = prefs.getString('login')!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    setState(() {
      getLogin();
    });

    return SafeArea(
        child: FutureBuilder(
      future: futureLoging,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Scaffold(
            body: LiquidLinearProgressIndicator(
              value: 0.25, // Defaults to 0.5.
              valueColor: AlwaysStoppedAnimation(
                  Colors.pink), // Defaults to the current Theme's accentColor.
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
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text('Confirm Registration'),
                centerTitle: true,
                backgroundColor: primaryColor,
              ),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                            'A verification code was sent to +216*****${_login.substring(9)} to activate your account\n'),
                        TextFormField(
                          autofocus: false,
                          validator: (value) => value!.isEmpty
                              ? "No verif code provided !"
                              : null,
                          onSaved: (value) => _verifCode = value!,
                          decoration: buildInputDecoration(
                              "Enter the verif code sent to you",
                              Icons.message),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ElevatedButton(
                            child: Text('Verify'),
                            style:
                                ElevatedButton.styleFrom(primary: primaryColor),
                            onPressed: () {
                              final form = _formKey.currentState;
                              print('---> login from pref: ${_login}');
                              if (form!.validate()) {
                                form.save();
                                final Future<Map<String, dynamic>>
                                    successfulMessage =
                                    auth.verifyNewUser(_login, _verifCode);
                                // auth.verifyUser(,)
                                successfulMessage.then((response) async {
                                  if (response['status']) {
                                    toastSuccessMsg(" Verification success !");
                                    await Future.delayed(
                                        const Duration(seconds: 3), () {});
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  } else {
                                    toastErrorMsg("  Verif Failed !");
                                  }
                                }).catchError((e) {
                                  print(
                                      "----> error 1 ${e.toString()}--------------------------------------------------------");
                                  toastErrorMsg("  Something went wrong !");
                                });
                              } else {
                                print("form is invalid");
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }
      },
    ));
  }
}
