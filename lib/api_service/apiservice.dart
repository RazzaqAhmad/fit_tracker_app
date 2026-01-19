import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:http_parser/http_parser.dart'; // Ensure this is in your pubspec.yaml

class ApiService {
  // Verified Laptop IP and Port
  static const String baseUrl = 'http://192.168.1.4:3000';

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  /// 1. POST Workout data
  Future<void> sendWorkout(
    String exercise,
    int sets,
    int reps,
    int weight,
    int duration,
  ) async {
    final url = Uri.parse('$baseUrl/add-workout');
    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              "exercise": exercise,
              "sets": sets,
              "reps": reps,
              "weight": weight,
              "duration": duration,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        debugPrint("✅ Workout sent successfully!");
      } else {
        debugPrint("❌ Server Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Workout Error: $e");
    }
  }

  /// 2. GET Workouts list
  Future<List<dynamic>> fetchWorkouts() async {
    final url = Uri.parse('$baseUrl/workouts');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("❌ Fetch Workouts Error: $e");
      return [];
    }
  }

  /// 3. GET Profile data
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get-profile'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint("❌ Fetch Profile Error: $e");
    }
    return null;
  }

  /// UPDATE Profile Text Data
  /// FIXED: Changed endpoint from '/update-profile' to '/save-profile'
  Future<bool> updateProfileText({
    required String name,
    required String age,
    required String weight,
    required String height,
    required String goal,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/save-profile'), // Must match server route
            headers: _headers,
            body: jsonEncode({
              "fullName": name,
              "age": age,
              "weight": weight,
              "height": height,
              "fitnessGoal": goal,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Profile updated!");
        return true;
      }
    } catch (e) {
      debugPrint("❌ Profile Update Error: $e");
    }
    return false;
  }

  /// 5. UPDATE Profile Image Separately
  /// This matches the app.post('/update-profile-image') route
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/update-profile-image'),
      );

      // Add the file
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage', // Field name must match Multer's upload.single('profileImage')
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("✅ Image uploaded: ${data['profileImage']}");
        return data['profileImage']; // Return the new filename
      }
    } catch (e) {
      debugPrint("❌ Image Upload Error: $e");
    }
    return null;
  } // --- THE METHOD THAT WAS MISSING ---

  /// Combined Save/Update Method
  Future<bool> saveProfileWithImage({
    required String name,
    required String age,
    required String weight,
    required String height,
    required String goal,
    File? image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/save-profile'), // Must match server route
      );

      request.fields['fullName'] = name;
      request.fields['age'] = age;
      request.fields['weight'] = weight;
      request.fields['height'] = height;
      request.fields['fitnessGoal'] = goal;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            image.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint("❌ ApiService Error: $e");
    }
    return false;
  }
}
