class Photo {
  final String uri;

  Photo({required this.uri});

  Photo.fromJson(Map<String, dynamic> parsedJson) : uri = parsedJson['uri'];
}
