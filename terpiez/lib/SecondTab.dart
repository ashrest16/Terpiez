import 'package:flutter/material.dart';
import 'package:terpiez/AppState.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';


class SecondTab extends StatelessWidget {
  const SecondTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
        builder: (context, value, child){
        return SafeArea(
          child: OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait){
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Terpiez Finder", style: TextStyle(fontSize: 40)),
                        LayoutBuilder(
                          builder: (context, constraints) =>
                              GestureDetector(
                                child: Icon(Icons.map_rounded,
                                    size: 0.8 * constraints.biggest.shortestSide),
                                onTap: (){
                                  value.appdata.terpiez += 1;
                                }
                              ),),
                        const Column(
                          children: [
                            Text("Closest Terpiez: ",
                              style: TextStyle(fontSize: 18),),
                            Text("123.0m",
                              style: TextStyle(fontSize: 18),),
                          ],
                        ),
                      ],
                    );
                }
                else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) =>
                                GestureDetector(
                                    child: Icon(Icons.map_rounded,
                                        size: 0.8 * constraints.biggest.shortestSide),
                                    onTap: (){
                                      value.appdata.terpiez += 1;
                                    }
                                )),
                        ),
                        const Center(
                          child: Column(
                            children: [
                              Text("Terpiez Finder", style: TextStyle(fontSize: 30)),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(50.0),
                          child: Column(
                            children: [
                              Text("Closest Terpiez: ",
                                style: TextStyle(fontSize: 18),),
                              Text("123.0m",
                                style: TextStyle(fontSize: 18),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
          ),
        );
      }
    );
  }
}
