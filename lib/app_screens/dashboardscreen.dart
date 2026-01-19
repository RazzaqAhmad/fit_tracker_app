import 'package:fit_tracker_app/app_screens/homescreen.dart';
import 'package:fit_tracker_app/app_screens/logworkoutscreen.dart';
import 'package:fit_tracker_app/app_screens/nutritionscreen.dart';
import 'package:fit_tracker_app/app_screens/profilescreen.dart';
import 'package:fit_tracker_app/app_screens/progressscreen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 1. Track the current active tab index
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const LogWorkoutScreen(),
    const NutritionScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. Update the body to show the current page from the list
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF8C3B),
      unselectedItemColor: Colors.grey,
      // 3. Link the current index to the UI
      currentIndex: _currentIndex,
      // 4. Add the logic to change pages when an icon is tapped
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Workout',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Nutrition',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
