class Location {
  final String? city;
  final String? country;
  final double latitude;
  final double longitude;

  Location(
      {required this.city,
      required this.country,
      required this.latitude,
      required this.longitude});

  Location.fromJson(Map<dynamic, dynamic> parsedJson)
      : city = parsedJson['city'],
        country = parsedJson['country'],
        latitude = parsedJson['latitudeCoordinates'],
        longitude = parsedJson['longitudeCoordinates'];
}
