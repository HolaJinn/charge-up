import 'dart:io';

import 'package:charge_up/domain/user.dart';
import 'package:charge_up/providers/auth_provider.dart';
import 'package:charge_up/providers/user_provider.dart';
import 'package:charge_up/util/shared_preference.dart';
import 'package:charge_up/util/widgets.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();

  String _firstName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String _role = '';
  String _password = '';
  String _confirmPassword = '';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String dropdownValue = 'CAR_OWNER';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Register'),
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    autofocus: false,
                    validator: (value) =>
                        value!.isEmpty ? 'This field is required' : null,
                    onSaved: (value) => _firstName = value!,
                    decoration: InputDecoration(
                        icon: Icon(Icons.text_fields),
                        border: OutlineInputBorder(),
                        labelText: 'First Name'),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    autofocus: false,
                    validator: (value) =>
                        value!.isEmpty ? 'This field is required' : null,
                    onSaved: (value) => _lastName = value!,
                    decoration: InputDecoration(
                        icon: Icon(Icons.text_fields),
                        border: OutlineInputBorder(),
                        labelText: 'Last Name'),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    autofocus: false,
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'This field is required' : null,
                    onSaved: (value) => _password = value!,
                    decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                        labelText: 'Password'),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    autofocus: false,
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'This field is required' : null,
                    // validator: (value)=> (value.isEmpty)?'This field is required':(value != _password)?'Password mismatch':null,
                    onSaved: (value) => _confirmPassword = value!,
                    decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password'),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    autofocus: false,
                    validator: (value) =>
                        value!.isEmpty ? 'This field is required' : null,
                    onSaved: (value) => _phoneNumber = value!,
                    decoration: InputDecoration(
                        icon: Icon(Icons.call),
                        border: OutlineInputBorder(),
                        labelText: 'Phone number'),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.grey[600],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: <String>['CAR_OWNER', 'STATION_OWNER']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'If you own a station please select the ROLE_STATION_OWNER option.',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: ElevatedButton(
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(primary: primaryColor),
                        onPressed: () {
                          final form = _formKey.currentState;
                          if (form!.validate()) {
                            form.save();
                            _role = dropdownValue;
                            Provider.of<AuthProvider>(context, listen: false)
                                .register(_firstName, _lastName, _password,
                                    _phoneNumber, _role)
                                .then((response) async {
                              if (response['status']) {
                                toastSuccessMsg("  Registration success");
                                await Future.delayed(
                                    const Duration(seconds: 5), () {});
                                User registeredUser = User.fromJson(Map.of(
                                    {'login': _phoneNumber, 'role': _role}));
                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .setUser(registeredUser);
                                UserPreferences().saveUser(registeredUser);
                                Navigator.pushReplacementNamed(
                                    context, '/confirm_register');
                              } else {
                                print('---> Error msg: ${response['data']}');
                                var errorCode = response['data']['errorCode'];
                                if (errorCode == 'USER_EXISTS')
                                  toastErrorMsg(
                                      "  Registration failed,\n  User with same phone number already exists !");
                                else if (errorCode == 'INVALID_USER')
                                  toastErrorMsg(
                                      "  Registration failed, Make sure you have provided valid infos !");
                                else
                                  toastErrorMsg(
                                      "  Registration failed, Something went wrong !");
                              }
                            });
                          } else {
                            toastErrorMsg("  All fields are required !");
                          }
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
