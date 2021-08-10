import 'package:charge_up/models/address.dart';
import 'package:charge_up/models/photo.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final bool activated;
  final String role;
  final Address address;
  //final Photo photo;

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phoneNumber,
      required this.activated,
      required this.role,
      required this.address});

  User.fromJson(Map<dynamic, dynamic> parsedJson)
      : id = parsedJson['id'],
        firstName = parsedJson['firstName'],
        lastName = parsedJson['lastName'],
        email = parsedJson['email'],
        phoneNumber = parsedJson['phoneNumber'],
        activated = parsedJson['activated'],
        role = parsedJson['role'],
        address = Address.fromJson(parsedJson['address']);
}
