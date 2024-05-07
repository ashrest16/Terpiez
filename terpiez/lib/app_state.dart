import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:redis/redis.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'terpiez_class.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppData {
  int count;
  String id;
  int initialDate;

  AppData({required this.count, required this.id, required this.initialDate});
}

class AppState extends ChangeNotifier {
  Set<Marker> terps = {};
  Marker _closestTerp =
      const Marker(markerId: MarkerId("Dummy"), position: LatLng(0, 0));
  List<dynamic> terpCaught = [];
  List<Map<String, dynamic>> totalTerpCaught = [];
  List<Terpiez> terpiezCaught = [];
  LatLng _currentPosition = const LatLng(38.9891, -76.9365); // Default value
  double _closestDistance = double.infinity;
  StreamSubscription<Position>? _locationSubscription;
  GoogleMapController? _mapController;
  late CameraPosition _cameraPosition;
  final storage = const FlutterSecureStorage();
  late Command command;
  Map<String, List<dynamic>> toDatabase = {};
  String? username;
  String? password;
  bool previousAttempt = true;
  bool firstAttempt = true;
  bool connected = false;
  String snackbarMessage = "";
  bool snackbarFlag = false;

  AppData appdata = AppData(
      count: 0, id: "", initialDate: DateTime.now().millisecondsSinceEpoch);

  AppState() {
    _setState();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    command.get_connection().close();
    super.dispose();
  }

  Future<void> _setState() async {
    final prefs = await SharedPreferences.getInstance();
    String _id = prefs.getString('id') ?? const Uuid().v4();
    int _initialDate =
        prefs.getInt('initialDate') ?? DateTime.now().millisecondsSinceEpoch;
    await prefs.setString('id', _id);
    await prefs.setInt('initialDate', _initialDate);
    username = await storage.read(key: 'dbUsername');
    password = await storage.read(key: 'dbPassword');
    appdata.id = _id;
    appdata.initialDate = _initialDate;
    await loadTerpiezFromFile();
    if (username != null && password != null) {
      Timer.periodic(const Duration(seconds: 10), (timer) async {
        await _initializeRedisConnection();
        firstAttempt = false;
      });
    }
    closestTerpiez();
    _cameraPosition = CameraPosition(target: _currentPosition, zoom: 20);
    await _updateLocation();
  }

  Future<void> _initializeRedisConnection() async {
    final conn = RedisConnection();
    try {
      command = await conn
          .connect('cmsc436-0101-redis.cs.umd.edu', 6380)
          .timeout(const Duration(seconds: 1));
      await command.send_object(['AUTH', username, password]).timeout(
          const Duration(seconds: 1));
      print('Connected and authenticated');
      connected = true;
      if (previousAttempt == false && firstAttempt == false) {
        snackbarMessage = 'Connection has been restored';
        snackbarFlag = true;
        previousAttempt = true;
      }
      var result = await command.send_object(['JSON.GET', 'locations']);
      getTerpiez(jsonDecode(result));
      result = await command.send_object(['JSON.GET', 'ashrest']);
      result = jsonDecode(result);
      if (result != null && result.isNotEmpty) {
        var data = result;
        if (data[id] != null) {
          terpCaught = data[id];
        }
      }
      toDatabase[id] = terpCaught;
    } catch (e) {
      connected = false;
      if (previousAttempt == true && firstAttempt == false) {
        snackbarMessage = 'Connection has been lost';
        snackbarFlag = true;
      }
      previousAttempt = false;
    }
    notifyListeners();
  }

  Future<void> loadCredentials() async {
    username = await storage.read(key: 'dbUsername');
    password = await storage.read(key: 'dbPassword');
    notifyListeners();
  }

  bool get needCredentials => username == null || password == null;

  Future<void> loadTerpiezFromDatabase(String id, LatLng position) async {
    dynamic obj = await command.send_object(['JSON.GET', 'terpiez', ".$id"]);
    obj = jsonDecode(obj);
    dynamic thumbnail =
        await command.send_object(['JSON.GET', 'images', obj["thumbnail"]]);
    dynamic image =
        await command.send_object(['JSON.GET', 'images', obj["image"]]);
    obj['thumbnail'] = jsonDecode(thumbnail);
    obj['largeImage'] = jsonDecode(image);
    obj['location'] = {'lat': position.latitude, 'lon': position.longitude};
    terpiezCaught.add(Terpiez.fromJson(obj));
  }

  Future<void> loadTerpiezFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/terpiez_data.json');
    bool doesFileExists = await file.exists();
    if (!doesFileExists) {
      await file.create();
    } else {
      String contents = await file.readAsString();
      if (contents.isEmpty) {
        terpiezCaught = [];
      } else {
        try {
          dynamic decoded = jsonDecode(contents);
          for (dynamic element in decoded) {
            terpiezCaught.add(Terpiez.fromJson(element));
            appdata.count += 1;
          }
        } catch (e) {
          print("Error decoding JSON: $e");
          terpiezCaught = [];
        }
      }
    }
  }

  Future<void> writeTerpiezToFile() async {
    final contents =
        jsonEncode(terpiezCaught.map((element) => element.toJson()).toList());
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/terpiez_data.json');
    bool doesFileExists = await file.exists();
    if (!doesFileExists) {
      await file.create();
    }
    await file.writeAsString(contents);
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
    if (connected){
      double closestDistance = double.infinity;
      for (var marker in terps) {
        double distance = calculateDistance(marker.position);
        if (distance < closestDistance &&
            !terpCaught.contains(marker.markerId.value)) {
          closestDistance = distance;
          _closestTerp = marker;
        }
      }
      _closestDistance = closestDistance * 1000;
      notifyListeners();
    }
  }

  int get terpiez => appdata.count;

  String get id => appdata.id;

  int get initialDate => appdata.initialDate;

  double get closestDistance => _closestDistance;

  LatLng get currentPosition => _currentPosition;

  CameraPosition get cameraPosition => _cameraPosition;

  GoogleMapController? get mapController => _mapController;

  Marker get closestTerp => _closestTerp;

  void getTerpiez(json) {
    for (var x in json) {
      var y = Marker(
          markerId: MarkerId(x['id']), position: LatLng(x['lat'], x['lon']));
      terps.add(y);
    }
    closestTerpiez();
  }

  Future<void> addToTerpCaught(MarkerId x, LatLng position) async {
    terpCaught.add(x.value);
    appdata.count += 1;
    terps.removeWhere((marker) => marker.markerId == x);
    closestTerpiez();
    await loadTerpiezFromDatabase(x.value, position);
    await writeTerpiezToFile();
    await command
        .send_object(['JSON.SET', 'ashrest', ".", jsonEncode(toDatabase)]);
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
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _locationSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _cameraPosition = CameraPosition(target: _currentPosition, zoom: 20);
      _mapController
          ?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
      closestTerpiez();
      notifyListeners();
    });
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }
}
