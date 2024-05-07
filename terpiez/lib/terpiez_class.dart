import 'package:google_maps_flutter/google_maps_flutter.dart';

class Terpiez{
  String name;
  Map<String,dynamic> stats;
  String largeImage;
  String thumbnail;
  String description;
  CameraPosition location;

  Terpiez({
    required this.name,
    required this.stats,
    required this.largeImage,
    required this.thumbnail,
    required this.description,
    required this.location
  });
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "stats": stats,
      "largeImage": largeImage,
      "thumbnail": thumbnail,
      "description": description,
      "location": {
        "lat": location.target.latitude,
        "lon": location.target.longitude,
      }
    };
  }
  factory Terpiez.fromJson(Map<String, dynamic> json) {
    LatLng latLng = LatLng(json["location"]["lat"], json["location"]["lon"]);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 20);

    return Terpiez(
        name: json["name"],
        stats: json["stats"],
        largeImage: json["largeImage"],
        thumbnail: json["thumbnail"],
        description: json["description"],
        location: cameraPosition
    );
  }
}
