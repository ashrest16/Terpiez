import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TerpiezState extends ChangeNotifier {
  final terps = {
    const Marker(
      markerId: MarkerId("terpiez1"),
      position: LatLng(38.992600, -76.938900),
    ),
    const Marker(
      markerId: MarkerId("terpiez2"),
      position: LatLng(38.989800, -76.935800),
    ),
    const Marker(
      markerId: MarkerId("terpiez3"),
      position: LatLng(38.990400, -76.935500),
    ),
    const Marker(
      markerId: MarkerId("terpiez4"),
      position: LatLng(38.991400, -76.935800),
    ),
    const Marker(
      markerId: MarkerId("terpiez5"),
      position: LatLng(38.992900, -76.936700),
    ),
  };

  LatLng _currentPosition = const LatLng(0, 0); // Default value
  double _closestDistance = double.infinity;
  StreamSubscription<Position>? _locationSubscription;
  GoogleMapController? _mapController;
  late CameraPosition _cameraPosition;

  TerpiezState() {
    _cameraPosition = CameraPosition(target: _currentPosition, zoom: 20);
    _updateLocation();
  }

  double calculateDistance(LatLng markerLocation) {
    var lat1 = _currentPosition.latitude;
    var lon1 = _currentPosition.longitude;
    var lat2 = markerLocation.latitude;
    var lon2 = markerLocation.longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void closestTerpiez() {
    double closestDistance = double.infinity;
    for (var marker in terps) {
      double distance = calculateDistance(marker.position);
      if (distance < closestDistance) {
        closestDistance = distance;
      }
    }
    _closestDistance = closestDistance * 1000;
    notifyListeners();
  }

  double get closestDistance => _closestDistance;
  LatLng get currentPosition => _currentPosition;
  CameraPosition get cameraPosition => _cameraPosition;
  GoogleMapController? get mapController => _mapController;


  Future<void> _updateLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permission is Denied');
      }
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _locationSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _cameraPosition = CameraPosition(target: _currentPosition, zoom: 20);
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
      closestTerpiez();
    });
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }
  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
