import 'package:charge_up/domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {
  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt("userId", user.userId);
    prefs.setString("firstName", user.firstName);
    prefs.setString("lastName", user.lastName);
    prefs.setString("login", user.login);
    prefs.setString("phone", user.phone);
    prefs.setString("role", user.role);
    prefs.setString("token", user.token);
    prefs.setString("photoUri", user.photoUri);

    // ignore: deprecated_member_use
    return prefs.commit();
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int userId = prefs.getInt("userId") ?? 1;
    String firstName = prefs.getString("firstName") ?? '';
    String lastName = prefs.getString("lastName") ?? '';
    String login = prefs.getString("login") ?? '';
    String phone = prefs.getString("phone") ?? '';
    String role = prefs.getString("role") ?? '';
    String token = prefs.getString("token") ?? '';
    String photoUri = prefs.getString("photoUri") ?? '';
    String verifCode = prefs.getString("verifCode") ?? '';
    bool isActive = prefs.getBool("isActive") ?? false;

    return User(
        userId: userId,
        login: login,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
        token: token,
        photoUri: photoUri,
        verifCode: verifCode,
        isActive: isActive);
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("userId");
    prefs.remove("firstName");
    prefs.remove("lastName");
    prefs.remove("photoUri");
    prefs.remove("login");
    prefs.remove("phone");
    prefs.remove("role");
    prefs.remove("token");
    prefs.remove("verifCode"); //todo remove this
    prefs.remove("isActive");
  }

  Future<String?> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token;
  }
}
