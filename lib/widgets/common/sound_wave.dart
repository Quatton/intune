import 'dart:math';

import 'package:flutter/material.dart';

class SoundWave extends StatefulWidget {
  // add colors, frequency range (start and end), thickness range, and size range as fields
  final Color color;
  final double frequency;
  final double frequencyRange;
  final double thickness;
  final double thicknessRange;
  final double height;
  final Duration duration;
  final double speed;

  const SoundWave(
      {super.key,
      this.color = Colors.blue,
      this.frequency = 0,
      this.frequencyRange = 100,
      this.thickness = 2,
      this.thicknessRange = 2,
      this.height = 50,
      this.duration = const Duration(seconds: 2),
      this.speed = 10});

  @override
  _SoundWaveState createState() => _SoundWaveState();
}

class _SoundWaveState extends State<SoundWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _frequency = 0.0;
  double _thickness = 2.0;

  @override
  void initState() {
    super.initState();
    _frequency = widget.frequency;
    _thickness = widget.thickness;
    _animationController = AnimationController(vsync: this);
    _animationController.repeat(
        reverse: true, period: widget.duration, min: 0, max: 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        _frequency = widget.frequency +
            _animationController.value * widget.frequencyRange;
        _thickness = widget.thickness +
            _animationController.value * widget.thicknessRange;
        return CustomPaint(
          painter: SoundWavePainter(
              frequency: _frequency,
              thickness: _thickness,
              color: widget.color,
              speed: widget.speed,
              value: _animationController.value),
          size: Size.fromHeight(widget.height),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class SoundWavePainter extends CustomPainter {
  final double frequency;
  final double thickness;
  final Color color;
  final double speed;
  final double value;

  SoundWavePainter(
      {required this.frequency,
      required this.thickness,
      required this.color,
      required this.speed,
      required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final path = Path();

    final y = size.height / 2;
    final width = size.width;
    final height = size.height;

    path.moveTo(0, y);

    for (double i = 0; i < width; i++) {
      final x = speed * value + i; // + (frequency * sin(i / width * pi * 2));
      final y = height / 2 + sin(x * pi * 2 / width * frequency) * height / 2;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) {
    return oldDelegate.frequency != frequency ||
        oldDelegate.thickness != thickness;
  }
}
