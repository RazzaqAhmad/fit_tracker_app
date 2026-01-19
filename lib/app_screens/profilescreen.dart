import 'dart:io';
import 'package:fit_tracker_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'setgoal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // --- New Variables for Reminders ---
  TimeOfDay _waterTime = const TimeOfDay(hour: 08, minute: 00);
  TimeOfDay _workoutTime = const TimeOfDay(hour: 17, minute: 00);

  String? _selectedGoal;
  bool _isUploading = false;
  bool _workoutReminders = true;
  bool _waterIntake = false;

  final List<String> _goals = [
    "Lose Weight",
    "Gain Muscle",
    "Stay Fit",
    "Endurance",
  ];
  final String serverUrl = "http://192.168.1.4:3000";
  Future<Map<String, dynamic>?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = fetchUserProfile();
  }

  // --- Time Picker Logic ---
  Future<void> _selectTime(BuildContext context, String type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: type == 'water' ? _waterTime : _workoutTime,
    );
    if (picked != null) {
      setState(() {
        if (type == 'water') {
          _waterTime = picked;
          if (_waterIntake) _scheduleNotification('water');
        } else {
          _workoutTime = picked;
          if (_workoutReminders) _scheduleNotification('workout');
        }
      });
    }
  }

  void _scheduleNotification(String type) {
    if (type == 'water') {
      NotificationService.showScheduledNotification(
        id: 101,
        title: "Drink Water! 💧",
        body: "It's time for your scheduled hydration.",
        hour: _waterTime.hour,
        minute: _waterTime.minute,
      );
    } else {
      NotificationService.showScheduledNotification(
        id: 102,
        title: "Workout Time! 🏋️",
        body: "Time to hit your daily fitness goal!",
        hour: _workoutTime.hour,
        minute: _workoutTime.minute,
      );
    }
  }

  void _onNotificationToggle(bool value, String type) {
    setState(() {
      if (type == 'workout') {
        _workoutReminders = value;
        if (value) {
          _scheduleNotification('workout');
        } else {
          NotificationService.cancelNotification(102);
        }
      } else {
        _waterIntake = value;
        if (value) {
          _scheduleNotification('water');
        } else {
          NotificationService.cancelNotification(101);
        }
      }
    });
  }

  // (Keeping your existing fetchUserProfile, updateFullProfile, and pickAndUploadImage logic...)
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/get-profile'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      debugPrint("Network Error: $e");
    }
    return null;
  }

  Future<void> _updateFullProfile() async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/save-profile'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "fullName": _nameController.text,
          "age": _ageController.text,
          "weight": _weightController.text,
          "height": _heightController.text,
          "fitnessGoal": _selectedGoal,
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          _profileFuture = fetchUserProfile();
        });
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$serverUrl/save-profile'),
        );
        request.files.add(
          await http.MultipartFile.fromPath('profileImage', pickedFile.path),
        );
        var res = await request.send();
        if (res.statusCode == 200) {
          setState(() {
            _profileFuture = fetchUserProfile();
            _isUploading = false;
          });
        }
      } catch (e) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE52E71)),
            );
          }
          if (snapshot.hasError || snapshot.data == null)
            return _buildErrorState();

          final userData = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildDynamicHeader(
                  userData['fullName'] ?? 'User',
                  userData['profileImage'],
                ),
                _buildSectionTitle('NOTIFICATIONS'),
                _buildSettingsCard([
                  _buildSwitchTile(
                    'Workout (${_workoutTime.format(context)})',
                    Icons.notifications_none,
                    Colors.orange,
                    _workoutReminders,
                    (v) => _onNotificationToggle(v, 'workout'),
                    onTap: () => _selectTime(context, 'workout'),
                  ),
                  _buildSwitchTile(
                    'Water (${_waterTime.format(context)})',
                    Icons.opacity,
                    Colors.blue,
                    _waterIntake,
                    (v) => _onNotificationToggle(v, 'water'),
                    onTap: () => _selectTime(context, 'water'),
                  ),
                ]),
                _buildSectionTitle('ACCOUNT'),
                _buildSettingsCard([
                  _buildNavigationTile(
                    'Edit Profile',
                    Icons.person_outline,
                    Colors.grey,
                    onTap: () => _showEditSheet(userData),
                  ),
                  _buildNavigationTile(
                    'Help & Support',
                    Icons.help_outline,
                    Colors.grey,
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 30),
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI HELPERS (Updated SwitchTile to support Tap) ---

  Widget _buildSwitchTile(
    String t,
    IconData i,
    Color c,
    bool v,
    Function(bool) onChanged, {
    VoidCallback? onTap,
  }) => ListTile(
    onTap: onTap, // Click the text to change time
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(i, color: c, size: 20),
    ),
    title: Text(t, style: const TextStyle(fontSize: 15)),
    trailing: Switch.adaptive(
      value: v,
      activeColor: const Color(0xFFE52E71),
      onChanged: onChanged,
    ),
  );

  // (... Rest of your UI helper methods: _buildDynamicHeader, _buildErrorState, _showEditSheet, etc.)
  // Note: Copy your original _buildDynamicHeader, _buildErrorState, _showEditSheet, _buildLogoutButton, _buildSectionTitle, _buildSettingsCard, and _buildNavigationTile here.

  Widget _buildDynamicHeader(String name, String? profileImage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8C3B), Color(0xFFE52E71)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome back,",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: profileImage != null
                  ? ClipOval(
                      child: Image.network(
                        '$serverUrl/uploads/$profileImage',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() => const Center(child: Text("Connection Lost"));

  void _showEditSheet(Map<String, dynamic> data) {
    /* ... keep your original code ... */
  }

  Widget _buildLogoutButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ElevatedButton(onPressed: () {}, child: const Text("Log Out")),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );

  Widget _buildSettingsCard(List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(children: children),
  );

  Widget _buildNavigationTile(
    String t,
    IconData i,
    Color c, {
    required VoidCallback onTap,
  }) => ListTile(
    leading: Icon(i, color: c),
    title: Text(t),
    onTap: onTap,
  );
}
