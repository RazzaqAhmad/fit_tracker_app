import 'package:flutter/material.dart';
import 'package:fit_tracker_app/api_service/apiservice.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  // 1. Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // 2. Logic: Sends 'exercise' to match your Backend Schema
  void _saveWorkout() async {
    final String exerciseName = _nameController.text.trim();
    final int sets = int.tryParse(_setsController.text) ?? 0;
    final int reps = int.tryParse(_repsController.text) ?? 0;
    final int weight = int.tryParse(_weightController.text) ?? 0;
    final int duration = int.tryParse(_durationController.text) ?? 0;

    if (exerciseName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an exercise name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // NOTE: We pass exerciseName which the ApiService sends as "exercise" to Node.js
      await _apiService.sendWorkout(exerciseName, sets, reps, weight, duration);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout Saved Successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear fields after success
        _nameController.clear();
        _setsController.clear();
        _repsController.clear();
        _weightController.clear();
        _durationController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: Could not reach server.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // 1. Header with Gradient
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8C3B), Color(0xFFE52E71)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Log Workout',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balancing the back button
              ],
            ),
          ),

          // 2. Input Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Exercise Name"),
                  _buildTextField(
                    "e.g., Bench Press",
                    _nameController,
                    TextInputType.text,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInputGroup("Sets", "3", _setsController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputGroup("Reps", "12", _repsController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputGroup(
                          "Weight (kg)",
                          "60",
                          _weightController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Duration (minutes)"),
                  _buildTextField(
                    "45",
                    _durationController,
                    TextInputType.number,
                  ),
                  const SizedBox(height: 25),

                  // Recent Exercises Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recent Exercises",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildRecentItem(
                          "Bench Press",
                          "3 sets x 12 reps • 60kg",
                          Icons.fitness_center,
                          Colors.orange.shade50,
                        ),
                        _buildRecentItem(
                          "Squats",
                          "4 sets x 10 reps • 80kg",
                          Icons.show_chart,
                          Colors.green.shade50,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Save Workout Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8C3B), Color(0xFFE52E71)],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Workout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    TextInputType type,
  ) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildInputGroup(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        _buildTextField(hint, controller, TextInputType.number),
      ],
    );
  }

  Widget _buildRecentItem(
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFE52E71), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: TextButton(
        onPressed: () {
          _nameController.text = title;
        },
        child: const Text(
          "Use",
          style: TextStyle(
            color: Color(0xFFFF8C3B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
