import 'package:flutter/material.dart';
import 'package:flutter_playgorund/screen/google_maps/default_maps.dart';
import 'package:flutter_playgorund/widget/button.dart';

class Maps extends StatelessWidget {
  const Maps({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            Button(
              title: "Default Maps",
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DefaultMaps(),
                  ),
                );
              },
            ),
            Button(
              title: "Draw Two Points on Maps",
              onClick: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}
