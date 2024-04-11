import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ThirdTab extends StatelessWidget {
  const ThirdTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ['Bug', 'Plane'];
    final icons = [Icons.bug_report_rounded, Icons.airplanemode_active];
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        String itemTitle = items[index];
        IconData itemIcon = icons[index];
        return ListTile(
          title: Text(items[index], style: const TextStyle(fontSize: 40),),
          leading: Hero(
              tag: itemTitle,
              child: Icon(icons[index],size: 45,)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherView(itemIcon: itemIcon, itemTitle: itemTitle),
              ),
            );
          },
        );
      },
    );
  }
}

class OtherView extends StatelessWidget {
  final IconData itemIcon;
  final String itemTitle;

  const OtherView({super.key, required this.itemIcon, required this.itemTitle});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(itemTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) =>
           ShaderWidget(
             child: Center(
              child: Column(
                children: [
                  Hero(
                      tag: itemTitle,
                      child: Icon(itemIcon, size: 0.7 * constraints.biggest.shortestSide)),
                  Text(itemTitle, style: const TextStyle(fontSize: 48),),
             
                ],
              ),
                       ),
           ),
    ),
    );
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