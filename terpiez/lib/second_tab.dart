
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terpiez/app_state.dart';
import 'package:provider/provider.dart';

import 'package:terpiez/user_data.dart';

class SecondTab extends StatefulWidget {
  const SecondTab({super.key});

  @override
  State<SecondTab> createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  @override
  Widget build(BuildContext context) {
    final terpProvider = Provider.of<TerpiezState>(context);
    final appProvider = Provider.of<AppState>(context);
    final terp = terpProvider.terps;
    final closestTerp = terpProvider.closestDistance;
    final position = terpProvider.cameraPosition;
    return SafeArea(
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          terpProvider.setMapController(controller);
                        },
                        markers: terp,
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
                        "${closestTerp.toStringAsFixed(2)} meters",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: (closestTerp > 10.00) ? null :
                      () => appProvider.updateTerpiez(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Catch it!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      )
                  ),
                ],
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Closest Terpiez: ",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${closestTerp.toStringAsFixed(2)} meters",
                            style: const TextStyle(fontSize: 16),
                          ),
                          ElevatedButton(
                              onPressed: (closestTerp > 10.00) ? null :
                                  () => appProvider.updateTerpiez(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text(
                                "Catch it!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              )
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 190,
                        width: 500,
                        child: GoogleMap(
                          initialCameraPosition: position,
                          myLocationEnabled: true,
                          zoomControlsEnabled: false,
                          onMapCreated: (GoogleMapController controller) {
                            terpProvider.setMapController(controller);
                          },
                          markers: terp,
                        ),
                      ),
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
}
