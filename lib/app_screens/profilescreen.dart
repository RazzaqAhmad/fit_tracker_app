import 'dart:io';
import 'package:fit_tracker_app/api_service/apiservice.dart';
import 'package:fit_tracker_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
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

  // Reminder Times
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
  Future<Map<String, dynamic>?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService().fetchUserProfile();
  }

  // --- Notification Logic ---
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

  // --- API Actions using ApiService ---
  Future<void> _updateFullProfile() async {
    // CORRECTED: Using Named Parameters as defined in your ApiService
    final result = await ApiService().updateProfileText(
      name: _nameController.text,
      age: _ageController.text,
      weight: _weightController.text,
      height: _heightController.text,
      goal: _selectedGoal ?? _goals[0],
    );

    if (result) {
      setState(() {
        _profileFuture = ApiService().fetchUserProfile();
      });
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully!")),
      );
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

      final newImage = await ApiService().uploadProfileImage(
        File(pickedFile.path),
      );

      if (newImage != null) {
        setState(() {
          _profileFuture = ApiService().fetchUserProfile();
        });
      }
      setState(() => _isUploading = false);
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

  // --- UI Helpers ---
  Widget _buildDynamicHeader(String name, String? profileImage) {
    // CORRECTED: Accessing static baseUrl via Class name instead of instance
    final String baseUrl = ApiService.baseUrl;

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: ClipOval(
                    child: profileImage != null
                        ? Image.network(
                            '$baseUrl/uploads/$profileImage',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.person, color: Colors.white),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                ),
                if (_isUploading)
                  const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(Map<String, dynamic> data) {
    _nameController.text = data['fullName'] ?? '';
    _ageController.text = (data['age'] ?? '').toString();
    _weightController.text = (data['weight'] ?? '').toString();
    _heightController.text = (data['height'] ?? '').toString();
    _selectedGoal = _goals.contains(data['fitnessGoal'])
        ? data['fitnessGoal']
        : _goals[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Age",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Weight (kg)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Height (cm)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedGoal,
                  items: _goals
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setSheetState(() => _selectedGoal = val),
                  decoration: const InputDecoration(
                    labelText: "Fitness Goal",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _updateFullProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52E71),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Setgoal()),
            );
          }
        },
      ),
    );
  }

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
        const Text("Unable to load profile"),
        TextButton(
          onPressed: () => setState(() {
            _profileFuture = ApiService().fetchUserProfile();
          }),
          child: const Text("Retry"),
        ),
      ],
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ),
  );

  Widget _buildSettingsCard(List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: Column(children: children),
  );

  Widget _buildSwitchTile(
    String t,
    IconData i,
    Color c,
    bool v,
    Function(bool) onChanged, {
    VoidCallback? onTap,
  }) => ListTile(
    onTap: onTap,
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

  Widget _buildNavigationTile(
    String t,
    IconData i,
    Color c, {
    required VoidCallback onTap,
  }) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(i, color: c, size: 20),
    ),
    title: Text(t, style: const TextStyle(fontSize: 15)),
    trailing: const Icon(Icons.chevron_right, size: 20),
    onTap: onTap,
  );
}
