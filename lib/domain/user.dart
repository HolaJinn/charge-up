import 'package:jwt_decode/jwt_decode.dart';

class User {
  int userId;
  String firstName;
  String lastName;
  String login;
  String phone;
  String role;
  String token;
  String photoUri;
  String verifCode;
  bool isActive;
  User(
      {required this.userId,
      required this.firstName,
      required this.lastName,
      required this.login,
      required this.phone,
      required this.role,
      required this.token,
      required this.photoUri,
      required this.verifCode,
      required this.isActive});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
      login: responseData['login'] != null ? responseData['login'] : "***",
      role: responseData['role'] != null ? responseData['role'] : "***",
      token: responseData['token'] != null ? responseData['token'] : "***",
      userId: responseData['userId'] != null ? responseData['userId'] : -1,
      firstName: (responseData['firstName'] != null)
          ? responseData['firstName']
          : "***",
      lastName:
          (responseData['lastName'] != null) ? responseData['lastName'] : "***",
      phone: (responseData['phone'] != null) ? responseData['phone'] : "***",
      photoUri:
          (responseData['photoUri'] != null) ? responseData['photoUri'] : "***",
      verifCode: (responseData['verifCode'] != null)
          ? responseData['verifCode']
          : "***",
      isActive:
          (responseData['isActive'] != null) ? responseData['isActive'] : false,
    );
  }
}
