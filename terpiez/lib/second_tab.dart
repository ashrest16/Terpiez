import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terpiez/app_state.dart';
import 'package:provider/provider.dart';
import 'package:terpiez/shake.dart';
import 'package:audioplayers/audioplayers.dart';

class SecondTab extends StatefulWidget {
  const SecondTab({super.key});

  @override
  State<SecondTab> createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  final double _volume = 1.0;
  final AudioPlayer _player = AudioPlayer();
  final AssetSource _catch = AssetSource('sounds/caught.mp3');


  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppState>(context, listen: true);
    final shakeProvider = Provider.of<Shake>(context, listen: true);
    final closestDistance = appProvider.closestDistance;
    final closestTerp = appProvider.closestTerp;
    final position = appProvider.cameraPosition;
    final textColor = closestDistance <= 10.0 ? Colors.green : Colors.red;
    final message = appProvider.snackbarMessage;
    final snackbarFlag = appProvider.snackbarFlag;

    if (shakeProvider.shake && closestDistance <= 10.0) {
      Future.microtask(() => _catchTerp(context, appProvider, closestTerp, position));
    }
    if (snackbarFlag){
      Future.microtask(() {
        showSnackBar(context, message);
        appProvider.snackbarFlag = false;
      });
    }

    return SafeArea(
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Scaffold(
              body: Column(
                children: [
                  const Text("Terpiez Finder", style: TextStyle(fontSize: 40)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 400,
                      child: GoogleMap(
                        initialCameraPosition: position,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          appProvider.setMapController(controller);
                        },
                        markers: {closestTerp},
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        "Closest Terpiez: ",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "${closestDistance.toStringAsFixed(2)} meters",
                        style: TextStyle(fontSize: 18, color: textColor),
                      ),
                    ]
                ),
              ]
              ),
            );
          } else {
            return Scaffold(
              body: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      "Terpiez Finder",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 160,
                        width: 450,
                        child: GoogleMap(
                          initialCameraPosition: position,
                          myLocationEnabled: true,
                          zoomControlsEnabled: false,
                          onMapCreated: (GoogleMapController controller) {
                            appProvider.setMapController(controller);
                          },
                          markers: {closestTerp},
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            "Closest Terpiez: ",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${closestDistance.toStringAsFixed(2)} meters",
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }


  Future<void> _catchTerp(BuildContext context, AppState appProvider, Marker closestTerp, CameraPosition position) async {
    await appProvider.addToTerpCaught(closestTerp.markerId, position.target);
    final terpiezCount = appProvider.terpiezCaught.length;
    final recentCatch = appProvider.terpiezCaught[terpiezCount - 1];
    if (appProvider.sound) {
      _player.play(_catch, volume: _volume);
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              icon: Image.memory(base64Decode(recentCatch.largeImage)),
              title: Text(recentCatch.name),
              content: const Text('You Caught a Terp!!'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Okay'))
              ]);
        });
  }
  void showSnackBar(BuildContext context, String message){
    SnackBar snackBar = SnackBar(
        content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}



