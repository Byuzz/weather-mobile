import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://ir64-iot.weathertech.tech';
  
  // Inisialisasi Secure Storage
  static const _storage = FlutterSecureStorage();
  
  // Auth Methods
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          // Ganti SharedPreferences dengan Secure Storage
          await _storage.write(key: 'auth_token', value: data['token']);
          
          // Simpan user data sebagai JSON String
          if (data['user'] != null) {
            await _storage.write(key: 'user_data', value: jsonEncode(data['user']));
          }
          
          // Simpan status login untuk AuthProvider
          await _storage.write(key: 'is_logged_in', value: 'true');
          await _storage.write(key: 'username', value: username);
        }
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  static Future<void> logout() async {
    // Hapus semua data session dari Secure Storage
    await _storage.deleteAll();
  }
  
  static Future<String?> getToken() async {
    // Baca token dari Secure Storage
    return await _storage.read(key: 'auth_token');
  }
  
  // --- Sensor Data Methods (Tidak berubah, tapi siap untuk header token) ---
  
  static Future<List<dynamic>> getLatestSensorData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/latest/sensor'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch sensor data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  static Future<List<dynamic>> getSensorSystemData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/latest/sensor_system'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch sensor system data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  static Future<List<dynamic>> getGatewaySystemData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/latest/gateway_system'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch gateway system data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  static Future<List<dynamic>> getHistoryData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/history'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch history data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Fan Control
  static Future<Map<String, dynamic>> controlFan(String action) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/control/fan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Fan control failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}