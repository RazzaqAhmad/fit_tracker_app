import 'dart:io';
import 'package:fit_tracker_app/api_service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboardscreen.dart';

class Setgoal extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const Setgoal({super.key, this.existingData});

  @override
  State<Setgoal> createState() => _SetgoalState();
}

class _SetgoalState extends State<Setgoal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _selectedGoal = 'Lose Weight';
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['fullName'] ?? '';
      _ageController.text = (widget.existingData!['age'] ?? '').toString();
      _weightController.text = (widget.existingData!['weight'] ?? '')
          .toString();
      _heightController.text = (widget.existingData!['height'] ?? '')
          .toString();
      _selectedGoal = widget.existingData!['fitnessGoal'] ?? 'Lose Weight';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Please enter your name");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await ApiService().saveProfileWithImage(
        name: _nameController.text,
        age: _ageController.text,
        weight: _weightController.text,
        height: _heightController.text,
        goal: _selectedGoal,
        image: _imageFile,
      );

      if (success) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGoalSet', true);

        if (!mounted) return;

        _showSnackBar("Profile saved successfully!", isError: false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        _showSnackBar("Server rejected the update.");
      }
    } catch (e) {
      _showSnackBar("Connection error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.only(
                top: 240,
                left: 20,
                right: 20,
                bottom: 40,
              ),
              child: _buildFormCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8C3B), Color(0xFFE52E71)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Profile Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildAvatarPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : (widget.existingData?['profileImage'] != null
                      ? NetworkImage(
                              '${ApiService.baseUrl}/uploads/${widget.existingData!['profileImage']}',
                            )
                            as ImageProvider
                      : null),
            child:
                (_imageFile == null &&
                    widget.existingData?['profileImage'] == null)
                ? const Icon(Icons.person_outline, size: 60, color: Colors.grey)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C3B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Full Name"),
          _buildTextField("Enter your name", _nameController),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Age"),
                    _buildTextField("25", _ageController, isNumber: true),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Weight (kg)"),
                    _buildTextField("70", _weightController, isNumber: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel("Height (cm)"),
          _buildTextField("175", _heightController, isNumber: true),
          const SizedBox(height: 20),
          _buildLabel("Fitness Goal"),
          DropdownButtonFormField<String>(
            value: _selectedGoal,
            decoration: _inputDecoration(),
            items: ['Lose Weight', 'Gain Muscle', 'Keep Fit']
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) => setState(() => _selectedGoal = val!),
          ),
          const SizedBox(height: 30),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C3B), Color(0xFFE52E71)],
        ),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
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
                'Save Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF4A4A4A),
      ),
    ),
  );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
  );

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: _inputDecoration(hint: hint),
  );
}
