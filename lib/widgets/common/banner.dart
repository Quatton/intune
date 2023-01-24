import 'package:flutter/material.dart';

class LogoBanner extends StatelessWidget {
  const LogoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.music_note,
              size: 60,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              'Intune',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
