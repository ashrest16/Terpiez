import 'package:flutter/material.dart';


class SecondTab extends StatelessWidget {
  const SecondTab({Key? key});

  @override
  Widget build(BuildContext context) {
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
                          Icon(Icons.map_rounded,
                              size: 0.8 * constraints.biggest.shortestSide),),
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
                            Icon(Icons.map,
                                size: 0.8 * constraints.biggest.shortestSide),),
                    ),
                    Center(
                      child: Column(
                        children: [
                          const Text("Terpiez Finder", style: TextStyle(fontSize: 30)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Column(
                        children: [
                          const Text("Closest Terpiez: ",
                            style: TextStyle(fontSize: 18),),
                          const Text("123.0m",
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
}
