import 'dart:io';
import 'package:fit_tracker_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
// IMPORTANT: Update this import path to match your project structure
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

  // IMPORTANT: Ensure this IP matches your computer's current local IP
  final String serverUrl = "http://192.168.1.4:3000";
  Future<Map<String, dynamic>?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = fetchUserProfile();
  }

  // --- LOGIC METHODS ---

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/get-profile'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint("Network Error: $e");
    }
    return null;
  }

  void _onNotificationToggle(bool value, String type) {
    setState(() {
      if (type == 'workout') {
        _workoutReminders = value;
        if (value) {
          NotificationService.showInstantNotification(
            "Workout Reminders Active",
            "We'll notify you when it's time to hit the gym!",
          );
        }
      } else {
        _waterIntake = value;
        if (value) {
          NotificationService.showInstantNotification(
            "Water Intake Active",
            "Stay hydrated! I'll remind you to drink water.",
          );
        }
      }
    });
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
        final updatedFuture = fetchUserProfile();
        setState(() {
          _profileFuture = updatedFuture;
        });

        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Profile updated!")));
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

        var streamedResponse = await request.send();
        if (streamedResponse.statusCode == 200) {
          final updatedFuture = fetchUserProfile();
          setState(() {
            _profileFuture = updatedFuture;
            _isUploading = false;
          });
        }
      } catch (e) {
        debugPrint("Upload Error: $e");
        setState(() => _isUploading = false);
      }
    }
  }

  // --- BUILD METHOD ---

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

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          }

          final userData = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              final updatedData = fetchUserProfile();
              setState(() {
                _profileFuture = updatedData;
              });
              await updatedData;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildDynamicHeader(
                    userData['fullName'] ?? 'User',
                    userData['profileImage'],
                  ),
                  _buildSectionTitle('NOTIFICATIONS'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      'Workout Reminders',
                      Icons.notifications_none,
                      Colors.orange,
                      _workoutReminders,
                      (v) => _onNotificationToggle(v, 'workout'),
                    ),
                    _buildSwitchTile(
                      'Water Intake',
                      Icons.opacity,
                      Colors.blue,
                      _waterIntake,
                      (v) => _onNotificationToggle(v, 'water'),
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
            ),
          );
        },
      ),
    );
  }

  // --- UI HELPER METHODS ---

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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: ClipOval(
                    child: profileImage != null
                        ? Image.network(
                            '$serverUrl/uploads/$profileImage',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: Colors.white),
                          )
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                ),
                if (_isUploading)
                  const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.redAccent),
          const Text(
            "Connection Lost",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              final nextFuture = fetchUserProfile();
              setState(() {
                _profileFuture = nextFuture;
              });
            },
            child: const Text("Try Again"),
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

    String? dbGoal = data['fitnessGoal'];
    _selectedGoal = _goals.contains(dbGoal) ? dbGoal : _goals[0];

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
                  onChanged: (val) {
                    setSheetState(() => _selectedGoal = val);
                    _selectedGoal = val;
                  },
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
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
    ),
    child: Column(children: children),
  );

  Widget _buildSwitchTile(
    String t,
    IconData i,
    Color c,
    bool v,
    Function(bool) onChanged,
  ) => ListTile(
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
