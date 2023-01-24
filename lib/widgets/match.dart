import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<StatefulWidget> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  double _height = 800;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: _height,
          child: WaveWidget(
            config: CustomConfig(
              colors: [
                Colors.green.shade200,
                Colors.green.shade300,
                Colors.green.shade400,
                Colors.green.shade500,
              ],
              durations: [12000, 8000, 6000, 4800],
              heightPercentages: [
                0.65,
                0.71,
                0.73,
                0.75,
              ],
              blur: const MaskFilter.blur(BlurStyle.solid, 5),
            ),
            size: const Size(double.infinity, double.infinity),
            waveAmplitude: 50,
          ),
        ),
      ],
    );
  }
}
