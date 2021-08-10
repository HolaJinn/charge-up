class Address {
  final String city;
  final String country;

  Address({required this.city, required this.country});

  Address.fromJson(Map<String, dynamic> parsedJson)
      : city = parsedJson['city'],
        country = parsedJson['country'];
}
