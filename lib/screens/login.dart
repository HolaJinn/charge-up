import 'package:charge_up/constants.dart';
import 'package:charge_up/domain/user.dart';
import 'package:charge_up/providers/auth_provider.dart';
import 'package:charge_up/providers/user_provider.dart';
import 'package:charge_up/screens/register.dart';
import 'package:charge_up/util/widgets.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = new GlobalKey<FormState>();

  String _username = '';
  String _password = '';

  void toastMsg(String msg) {
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

  void toastInfoMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.lightBlueAccent,
      content: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          Text(msg),
        ],
      ),
      duration: Duration(seconds: 5),
    ));
  }

  void flushbarMessage(BuildContext context) {
    Flushbar(
      title: 'Login failed',
      message: 'Make sure you have entered correct credentials !',
      icon: Icon(
        Icons.error_outline_outlined,
        size: 28,
        color: Colors.red.shade300,
      ),
      leftBarIndicatorColor: Colors.blue.shade300,
      duration: Duration(seconds: 5),
    ).show(context);
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //AuthProvider auth = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Charge Up',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            centerTitle: true,
            backgroundColor: primaryColor,
          ),
          body: Padding(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          controller: nameController,
                          validator: (value) => value!.isNotEmpty
                              ? null
                              : 'This field is mandatory',
                          decoration: InputDecoration(
                              icon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                              labelText: 'Phone Number'),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          validator: (value) => value!.isNotEmpty
                              ? null
                              : 'This field is mandatory',
                          decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                              labelText: 'Password'),
                        ),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(fontSize: 18, color: primaryColor),
                          )),
                      Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ElevatedButton(
                            child: Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                            style:
                                ElevatedButton.styleFrom(primary: primaryColor),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _username = nameController.text;
                                _password = passwordController.text;
                                final Future<Map<String, dynamic>>
                                    successfulMessage =
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .login(_username, _password);

                                // todo check if user isn't active toast info_msg
                                successfulMessage.then((response) async {
                                  if (response['status']) {
                                    User user = response['user'];
                                    print('---> user : ${user.isActive}');
                                    Provider.of<UserProvider>(context,
                                            listen: false)
                                        .setUser(user);
                                    if (user.isActive)
                                      Navigator.pushReplacementNamed(
                                          context, '/home');
                                    else if (user.role == "ROLE_CAR_OWNER") {
                                      toastInfoMsg("  User not activated !");
                                      await Future.delayed(
                                          const Duration(seconds: 5), () {});
                                      Navigator.pushReplacementNamed(
                                          context, '/confirm_register');
                                    } else if (user.role ==
                                        "ROLE_STATION_OWNER")
                                      toastInfoMsg(
                                          "  Your account will be activated soon !");
                                    //todo if user not verified GOTO verif Page
                                  } else {
                                    // todo : fix FlushBar errors or keep using SnackBar
                                    // flushbarMessage(context);
                                    toastMsg(
                                        "  Login Failed !\n  Please check your credentials and try again");
                                  }
                                }).catchError((e) {
                                  print(
                                      "----> error : ${e.toString()}--------------------------------------------------------");
                                  toastMsg("  Something went wrong !");
                                });
                              } else {
                                toastMsg("  All fields are mandatory !");
                                print("form is invalid");
                              }
                            },
                          )),
                      Container(
                          child: Row(
                        children: <Widget>[
                          Text('Does not have account?'),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Register()));
                              },
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                    fontSize: 20, color: primaryColor),
                              ))
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ))
                    ],
                  ),
                ),
              ))),
    );
  }
}
