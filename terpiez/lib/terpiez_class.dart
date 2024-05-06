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
  factory Terpiez.fromJson(Map<String, dynamic> json, dynamic thumbnail,dynamic image,LatLng position) {
    return Terpiez(
      name: json["name"],
      stats: json["stats"],
      largeImage: image,
      thumbnail: thumbnail,
      description: json["description"],
      location: CameraPosition(target: position, zoom: 20)
    );
  }
}


