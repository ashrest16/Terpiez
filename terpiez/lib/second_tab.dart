import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terpiez/app_state.dart';
import 'package:provider/provider.dart';

class SecondTab extends StatefulWidget {
  const SecondTab({super.key});

  @override
  State<SecondTab> createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppState>(context,listen: true);
    final closestDistance = appProvider.closestDistance;
    final closestTerp = appProvider.closestTerp;
    final position = appProvider.cameraPosition;
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
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: (closestDistance > 10.00) ? null :
                          () => appProvider.addToTerpCaught(closestTerp.markerId,position.target),
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
                            style: const TextStyle(fontSize: 16),
                          ),
                          ElevatedButton(
                              onPressed: (closestDistance > 10.00) ? null :
                                  () => appProvider.addToTerpCaught(closestTerp.markerId,position.target),
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
}
