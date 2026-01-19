import 'package:flutter/material.dart';
import '../controllers/app_state.dart'; // Ensure this path matches your project

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for changes in the global state
    appState.addListener(_updateUI);
  }

  @override
  void dispose() {
    appState.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  // Function to show the "Add Meal" Dialog
  void _showAddMealDialog() {
    String mealTitle = "Snack";
    int mealCals = 200;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Quick Meal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Meal Name"),
              onChanged: (val) => mealTitle = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Calories"),
              keyboardType: TextInputType.number,
              onChanged: (val) => mealCals = int.tryParse(val) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              appState.addMeal(mealTitle, mealCals, ["Quick Entry"]);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int remaining = appState.calorieGoal - appState.caloriesConsumed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header with Global State Data
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF009473)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // IconButton(
                      //   icon: const Icon(Icons.arrow_back, color: Colors.white),
                      //   onPressed: () => Navigator.pop(context),
                      // ),
                      const SizedBox(width: 80),
                      const Text(
                        'Nutrition',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 80),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _showAddMealDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Calorie Goal',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${appState.caloriesConsumed}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 6,
                                  left: 4,
                                ),
                                child: Text(
                                  'of ${appState.calorieGoal} cal',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$remaining',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'remaining',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Macro-nutrient Cards (Linked to appState)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  _buildMacroCard(
                    '${appState.carbs}g',
                    'Carbs',
                    Colors.orange,
                    0.6,
                  ),
                  const SizedBox(width: 12),
                  _buildMacroCard(
                    '${appState.protein}g',
                    'Protein',
                    Colors.red,
                    0.8,
                  ),
                  const SizedBox(width: 12),
                  _buildMacroCard(
                    '${appState.fats}g',
                    'Fats',
                    Colors.yellow.shade700,
                    0.4,
                  ),
                ],
              ),
            ),

            // 3. Today's Meals Section (Dynamic List)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Meals",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _showAddMealDialog,
                        child: const Text(
                          'Add Meal',
                          style: TextStyle(color: Color(0xFF00B894)),
                        ),
                      ),
                    ],
                  ),
                  // This builds a card for every meal in appState.meals
                  ...appState.meals.map(
                    (meal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildMealCard(
                        meal['title'],
                        '${meal['cals']} cal',
                        Icons.restaurant_menu,
                        const Color(0xFFFFF4ED),
                        List<String>.from(meal['items']),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Interactive Water Intake Banner
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: () => appState.addWater(0.25), // Adds 250ml per click
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF00B894),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Water Intake',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${appState.waterConsumed.toStringAsFixed(1)} / ${appState.waterGoal} L',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Tap to add 250ml',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildMacroCard(
    String amount,
    String label,
    Color color,
    double progress,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_fire_department,
              color: color.withOpacity(0.5),
              size: 18,
            ),
            const SizedBox(height: 10),
            Text(
              amount,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(
    String title,
    String cals,
    IconData icon,
    Color bgColor,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.orange.shade700, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      cals,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 45, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map(
                    (item) => Text(
                      '• $item',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
