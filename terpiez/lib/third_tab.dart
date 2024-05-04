import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terpiez/terpiez_class.dart';

import 'app_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ThirdTab extends StatelessWidget {
  const ThirdTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppState>(context,listen: true);
    final catches = appProvider.terpiezCaught;
    final Set<String> addedItemNames = {};
    return ListView.builder(
      itemCount: catches.length,
      itemBuilder: (context, index) {
        String itemTitle = catches[index].name;
        if (addedItemNames.contains(itemTitle)) {
          // If duplicate, return an empty container
          return Container();
        } else {
          return ListTile(
            title: Text(itemTitle, style: const TextStyle(fontSize: 20),),
            leading: Hero(
                tag: itemTitle,
                child: Image.memory(base64Decode(catches[index].thumbnail))
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherView(elem: catches[index]),
                ),
              );
            },
          );
        }
      }
    );
  }
  }


class OtherView extends StatelessWidget {
  final Terpiez elem;

  const OtherView({super.key, required this.elem});

  @override
  Widget build(BuildContext context) {
    final String itemIcon = elem.largeImage;
    final String itemTitle = elem.name;
    final Map<String, dynamic> stats = elem.stats;
    final CameraPosition position = elem.location;
    return Scaffold(
        appBar: AppBar(
          title: Text(itemTitle),
        ),
        body: SafeArea(child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return LayoutBuilder(
                builder: (context, constraints) => ShaderWidget(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [
                          Hero(
                              tag: itemTitle,
                              child: Container(
                                width: 0.7 * constraints.biggest.shortestSide,
                                child: Image.memory(base64Decode(itemIcon)),
                              )),
                          Text(
                            itemTitle,
                            style: const TextStyle(
                                fontSize: 28, color: Colors.white),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 100,
                                width: 230,
                                child: GoogleMap(
                                  initialCameraPosition: position,
                                  zoomControlsEnabled: false,
                                  markers: {
                                    Marker(
                                        markerId: MarkerId(itemTitle),
                                        position: position.target)
                                  },
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: stats.entries
                                    .map((entry) => Text(
                                          '${entry.key}: ${entry.value.toString()}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ))
                                    .toList(),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              elem.description,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return LayoutBuilder(
                  builder: (context,constraints) =>
                  ShaderWidget(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        children: [
                          Hero(
                              tag: itemTitle,
                              child: Container(
                                width: 0.7 * constraints.biggest.shortestSide,
                                child: Image.memory(base64Decode(itemIcon)),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child:
                                    GoogleMap(
                                      initialCameraPosition: position,
                                      zoomControlsEnabled: false,
                                      markers: {
                                        Marker(
                                          markerId: MarkerId(itemTitle),
                                          position: position.target
                                        )
                                      },
                                    ),
                                ),
                                Column(
                                  children:
                                    stats.entries
                                        .map((entry) => Text(
                                      '${entry.key}: ${entry.value.toString()}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white),
                                    )).toList()
                                  ,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 300,
                              child: Text(elem.description,
                                style: const TextStyle(
                                    fontSize: 14,color: Colors.white
                                ),),
                            ),
                          )
                        ],
                      ),
                    ),
                  )));
            }
          },
        )));
  }
}

class ShaderPainter extends CustomPainter {
  ShaderPainter({required this.shader, required this.t});
  FragmentShader shader;
  double t;
  final int start = DateTime.now().millisecondsSinceEpoch;
  double get current =>
      1.0 * (DateTime.now().millisecondsSinceEpoch - start) / 1000;
  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, t * pi );
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ShaderWidget extends StatefulWidget {
  const ShaderWidget({super.key, required this.child});
  final Widget child;
  @override
  State<StatefulWidget> createState() => _ShaderState();
}
class _ShaderState extends State<ShaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => ShaderBuilder(
            assetKey: 'shaders/shaders.frag',
                (context, shader, child) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: ShaderPainter(shader: shader,
                  t: _controller.value),
              child: child,
            ),
            child: child),
        child: widget.child);
  }
}