class Charger {
  final bool available;
  final double chargingPrice;
  final String description;
  final int id;
  final double power;
  final String type;

  Charger(
      {required this.id,
      required this.available,
      required this.chargingPrice,
      required this.description,
      required this.power,
      required this.type});

  Charger.fromJson(Map<dynamic, dynamic> parsedJson)
      : id = parsedJson['id'],
        available = parsedJson['available'],
        chargingPrice = parsedJson['chargingPrice'],
        description = parsedJson['description'],
        power = parsedJson['power'],
        type = parsedJson['type'];
}
