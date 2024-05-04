import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:redis/redis.dart';
import 'terpiez_class.dart';
import 'credentials.dart';

class AppData {
  int count;
  String id;
  int initialDate;

  AppData({required this.count, required this.id, required this.initialDate});
}

class AppState extends ChangeNotifier {
  Set<Marker> terps = {};
  late Marker _closestTerp;
  Map<String,dynamic> terpCaught = {};
  List<Terpiez> terpiezCaught = [];

  LatLng _currentPosition = const LatLng(0, 0); // Default value
  double _closestDistance = double.infinity;
  StreamSubscription<Position>? _locationSubscription;
  GoogleMapController? _mapController;
  late CameraPosition _cameraPosition;

  late Command command;
  Map<String,Map<String,dynamic>> toDatabase = {};

  String? username;
  String? password;
  AppData appdata = AppData(count: 0, id: Uuid().v4(), initialDate: DateTime.now().millisecondsSinceEpoch);
  AppState(){
    _setState();
    _updateLocation();
    _cameraPosition = CameraPosition(target: _currentPosition, zoom: 20);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    command.get_connection().close();
    super.dispose();
  }

  Future<void> _setState()async {
    final prefs = await SharedPreferences.getInstance();
    String _id = prefs.getString('id') ?? const Uuid().v4();
    int _initialDate = prefs.getInt('initialDate') ?? DateTime.now().millisecondsSinceEpoch;
    await prefs.setString('id', _id);
    await prefs.setInt('initialDate', _initialDate);

    const storage = FlutterSecureStorage();
    await storage.write(key: 'dbUsername', value: 'ashrest');
    await storage.write(key: 'dbPassword', value: 'e45c09a18401401a8431a75a271e8260');
    username = await storage.read(key: 'dbUsername');
    password = await storage.read(key: 'dbPassword');
    appdata.id = _id;
    appdata.initialDate = _initialDate;
    final conn = RedisConnection();
    command = await conn.connect('cmsc436-0101-redis.cs.umd.edu', 6380);
    try {
      await command.send_object(['AUTH', username, password]);
      print('Connected and authenticated');
      var result = await command.send_object(['JSON.GET', 'locations']);
      getTerpiez(jsonDecode(result));
      result = await command.send_object(['JSON.GET', 'ashrest']);
      result = jsonDecode(result);
      if (result != null && result.isNotEmpty) {
        var data = result;
        if (data[id] != null) {
          terpCaught = data[id];
          appdata.count = terpCaught.length;
          terpCaught.forEach((key, value) {
            loadTerpiez(key, LatLng(value[0],value[1]));
          });
          print("here");
        } else {
          terpCaught = {};
        }
      }
      toDatabase[id] = terpCaught;
    } catch (e) {
      print('Error connecting to Redis: $e');
    }
    notifyListeners();
  }

  Future<void> loadTerpiez(String id, LatLng position) async {
    dynamic obj = await command.send_object(['JSON.GET','terpiez',".$id"]);
    obj = jsonDecode(obj);
    dynamic thumbnail = await command.send_object(['JSON.GET', 'images',obj["thumbnail"]]);
    dynamic image = await command.send_object(['JSON.GET', 'images',obj["image"]]);
    terpiezCaught.add(Terpiez.fromJson(obj,jsonDecode(thumbnail),
        jsonDecode(image),position));
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
      if (distance < closestDistance && !terpCaught.containsKey(marker.markerId.value)) {
        closestDistance = distance;
        _closestTerp = marker;
      }
    }
    _closestDistance = closestDistance * 1000;
    notifyListeners();
  }

  int get terpiez => appdata.count;
  String get id => appdata.id;
  int get initialDate => appdata.initialDate;
  double get closestDistance => _closestDistance;
  LatLng get currentPosition => _currentPosition;
  CameraPosition get cameraPosition => _cameraPosition;
  GoogleMapController? get mapController => _mapController;
  Marker get closestTerp => _closestTerp;

  void getTerpiez(json){
    for (var x in json) {
      var y = Marker(
          markerId: MarkerId(x['id']),
          position: LatLng(x['lat'],x['lon'])
      );
      terps.add(y);
    }
    closestTerpiez();
  }


  Future<void> addToTerpCaught(MarkerId x,position) async {
    terpCaught[x.value] = position;
    appdata.count += 1;
    loadTerpiez(x.value, position);
    terps.removeWhere((marker) => marker.markerId == x);
    closestTerpiez();
    print(toDatabase);
    await command.send_object(['JSON.SET','ashrest',".", jsonEncode(toDatabase)]);
    notifyListeners();
  }

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
}
