import 'package:fit_tracker_app/app_screens/setgoal.dart';
import 'package:flutter/material.dart';

class GetstartedScreen extends StatelessWidget {
  const GetstartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use extendBody to allow the gradient to flow behind the BottomNav if desired
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8C3B), // Vibrant Orange
              Color(0xFFE52E71), // Deep Pink/Magenta
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Circle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timeline, // Representing the pulse/heartbeat icon
                size: 60,
                color: Color(0xFFFF8C3B),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'FitTrack',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Your Personal Fitness Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 60),
            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the next screen or perform an action
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Setgoal()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF8C3B),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
