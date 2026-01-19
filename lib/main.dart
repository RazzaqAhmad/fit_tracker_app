import 'package:fit_tracker_app/app_screens/dashboardscreen.dart';
import 'package:fit_tracker_app/app_screens/getstartedscreen.dart';
import 'package:fit_tracker_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isGoalSet = prefs.getBool('isGoalSet') ?? false;
  runApp(MyApp(isGoalSet: isGoalSet));
}

class MyApp extends StatelessWidget {
  final bool isGoalSet;
  const MyApp({super.key, this.isGoalSet = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isGoalSet ? const DashboardScreen() : const GetstartedScreen(),
    );
  }
}
