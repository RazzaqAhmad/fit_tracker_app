import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // User Data
  String name = "User";
  String? profileImage;

  // Nutrition Data
  int calorieGoal = 2200;
  int caloriesConsumed = 1250;
  double waterGoal = 3.0;
  double waterConsumed = 2.1;

  // Macros
  int carbs = 142;
  int protein = 98;
  int fats = 52;

  List<Map<String, dynamic>> meals = [
    {
      'title': 'Breakfast',
      'cals': 520,
      'items': ['Oatmeal', 'Greek yogurt'],
    },
    {
      'title': 'Lunch',
      'cals': 680,
      'items': ['Grilled chicken', 'Brown rice'],
    },
  ];

  void addWater(double amount) {
    waterConsumed += amount;
    notifyListeners();
  }

  void updateName(String newName) {
    name = newName;
    notifyListeners(); // This automatically triggers your _refreshUI in HomeScreen
  }

  void addMeal(String title, int calories, List<String> items) {
    meals.add({'title': title, 'cals': calories, 'items': items});
    caloriesConsumed += calories;
    notifyListeners();
  }
}

final appState = AppState();
