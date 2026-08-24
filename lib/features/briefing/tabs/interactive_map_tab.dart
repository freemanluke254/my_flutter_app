import 'package:flutter/material.dart';

class InteractiveMapTab extends StatelessWidget {
  const InteractiveMapTab({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Interactive map',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      const Text(
        'Route, weather, alternates, NOTAMs and operational overlays will be combined here.',
        style: TextStyle(color: Color(0xFF667069)),
      ),
      const SizedBox(height: 20),
      Container(
        height: 330,
        decoration: BoxDecoration(
          color: const Color(0xFFDCEADD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public_rounded, size: 72, color: Color(0xFF173D31)),
            SizedBox(height: 14),
            Text(
              'Map preview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Import a package to build the route and operational overlays.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
