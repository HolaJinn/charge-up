import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:charge_up/domain/user.dart';
import 'package:charge_up/util/app_url.dart';
import 'package:charge_up/util/shared_preference.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut,
  IN_PROGRESS,
  COMPLETED
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;
  Status _verifiyingStatus = Status.COMPLETED;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;

  Status get verifiyingStatus => _verifiyingStatus;

  set verifiyingStatus(Status value) {
    _verifiyingStatus = value;
  }

  void set loggedInStatus(Status value) {
    _loggedInStatus = value;
  }

  void set registeredInStatus(Status value) {
    _registeredInStatus = value;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    var result;

    final Map<String, dynamic> loginData = {
      'login': email,
      'password': password
    };

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    Response response = await post(Uri.parse(AppUrl.login),
        body: json.encode(loginData),
        headers: {'Content-Type': 'application/json'}).catchError((e) {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
    });

    print("---> HTTP STATUS: ${response.statusCode}");
    print("---> HTTP RESPONSE:\n ${json.decode(response.body)}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      var token = responseData['token'];
      print('---> JWT token:\n ${token}');

      Map<String, dynamic> jwtToken = Jwt.parseJwt(responseData['token']);
      print('---> JwtToken values:\n ${jwtToken}');
      //*****************************************
      //*****************************************
      Response userInfo = await get(
          Uri.parse(AppUrl.userInfo + "/${jwtToken['userId']}"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }).catchError((e) {
        _loggedInStatus = Status.NotLoggedIn;
        notifyListeners();
      });
      Map<String, dynamic> userData = json.decode(userInfo.body);
      print("---> User info:\n");
      print(userData);

      Map<String, dynamic> data = new Map();
      data.putIfAbsent("userId", () => jwtToken['userId']);
      data.putIfAbsent("login", () => jwtToken['sub']);
      data.putIfAbsent("token", () => token);
      data.putIfAbsent("role", () => jwtToken['role']);

      data.putIfAbsent("firstName", () => userData['firstName']);
      data.putIfAbsent("lastName", () => userData['lastName']);
      data.putIfAbsent("isActive", () => userData['activated']);
      data.putIfAbsent("photoUri", () => userData['photo']['uri']);

      User authUser = User.fromJson(data);
      UserPreferences().saveUser(authUser);

      _loggedInStatus = Status.LoggedIn;
      notifyListeners();

      result = {'status': true, 'message': 'Successful', 'user': authUser};
    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {'status': false, 'message': json.decode(response.body)};
    }
    return result;
  }

  Future<Map<String, dynamic>> register(String firstName, String lastName,
      String password, String phone, String role) async {
    _registeredInStatus = Status.Registering;
    notifyListeners();
    var result;
    final Map<String, dynamic> registrationData = {
      "address": {'country': "Tunisia", 'city': "city"},
      "email": "string.strstr@hgfgh.com",
      "firstName": firstName,
      "lastName": lastName,
      "password": password,
      "phoneNumber": phone,
      "role": role
    };
    Response response = await post(Uri.parse(AppUrl.register),
        body: json.encode(registrationData),
        headers: {'Content-Type': 'application/json'}).catchError((e) {
      _registeredInStatus = Status.NotRegistered;
      notifyListeners();
    });
    print("---> Http status : ${response.statusCode}");
    if (response.statusCode == 201) {
      _registeredInStatus = Status.Registered;
      notifyListeners();
      print('---> User registered successfully !');
      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': {
          'login': phone,
        }
      };
    } else {
      _registeredInStatus = Status.NotRegistered;
      notifyListeners();
      final Map<String, dynamic> responseData = json.decode(response.body);
      print('---> Registration response :');
      print(responseData);
      result = {
        'status': false,
        'message': 'Registration failed',
        'data': responseData
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> verifyNewUser(String login, String code) async {
    var result;
    _verifiyingStatus = Status.IN_PROGRESS;
    notifyListeners();

    final Map<String, dynamic> verifRequest = {
      'login': login,
      'verifCode': code
    };
    Response response = await post(Uri.parse(AppUrl.verifyUser),
        body: json.encode(verifRequest),
        headers: {'Content-Type': 'application/json'}).catchError((e) {
      _verifiyingStatus = Status.COMPLETED;
      notifyListeners();
    });
    print("---> HTTP STATUS: ${response.statusCode}");
    print("---> HTTP RESPONSE:\n ${response.body}");
    _verifiyingStatus = Status.COMPLETED;
    notifyListeners();
    if (response.statusCode == 200) {
      result = {
        'status': true,
        'message': 'Verification success !',
      };
    } else {
      result = {
        'status': false,
        'message': 'Verification failed !',
      };
    }
    return result;
  }

  static onError(error) {
    print("the error is $error.detail");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }
}
