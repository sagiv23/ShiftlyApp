import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // כתובת השרת בענן (Render)
  static const String _baseUrl = 'https://shiftly-server.onrender.com/api';

  void _checkAuth(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('unauthorized');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    _checkAuth(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ??
            jsonDecode(response.body)['message'] ??
            'Login failed',
      );
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    DateTime? birthDate,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (birthDate != null) {
      final dateStr = birthDate.toIso8601String();
      body['birthDate'] = dateStr;
      body['birth_date'] = dateStr;
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    _checkAuth(response);
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ??
            jsonDecode(response.body)['message'] ??
            'Registration failed',
      );
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String token,
    String name,
    String email, {
    String? oldPassword,
    String? newPassword,
    DateTime? birthDate,
  }) async {
    final body = <String, dynamic>{'name': name, 'email': email};
    if (newPassword != null && newPassword.isNotEmpty) {
      body['oldPassword'] = oldPassword;
      body['newPassword'] = newPassword;
    }
    if (birthDate != null) {
      final dateStr = birthDate.toIso8601String();
      body['birthDate'] = dateStr;
      body['birth_date'] = dateStr;
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to update profile',
      );
    }
  }

  // --- Job Type Methods ---

  Future<List<dynamic>> getJobTypes(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/job-types'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkAuth(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load job types from server');
    }
  }

  Future<void> upsertJobType(
    String token,
    Map<String, dynamic> jobTypeData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/job-types'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(jobTypeData),
    );

    _checkAuth(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to sync job type to server');
    }
  }

  Future<void> batchUpsertJobTypes(
    String token,
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) return;
    final response = await http.post(
      Uri.parse('$_baseUrl/job-types/batch'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items}),
    );

    _checkAuth(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to batch sync job types to server');
    }
  }

  Future<void> deleteJobType(String token, String jobTypeId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/job-types/$jobTypeId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    _checkAuth(response);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete job type from server');
    }
  }

  // --- Shift Methods ---

  Future<List<dynamic>> getShifts(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shifts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkAuth(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load shifts from server');
    }
  }

  Future<void> upsertShift(String token, Map<String, dynamic> shiftData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/shifts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(shiftData),
    );

    _checkAuth(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to sync shift to server');
    }
  }

  Future<void> batchUpsertShifts(
    String token,
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) return;
    final response = await http.post(
      Uri.parse('$_baseUrl/shifts/batch'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items}),
    );

    _checkAuth(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to batch sync shifts to server');
    }
  }

  Future<void> deleteShift(String token, String shiftId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/shifts/$shiftId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    _checkAuth(response);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete shift from server');
    }
  }

  // --- Expense & Special Income Methods (Unified Table) ---

  Future<List<dynamic>> getExpenses(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/expenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkAuth(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load expenses from server');
    }
  }

  Future<void> upsertExpense(
    String token,
    Map<String, dynamic> expenseData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/expenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expenseData),
    );

    _checkAuth(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to sync expense to server');
    }
  }

  Future<void> batchUpsertExpenses(
    String token,
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) return;
    final response = await http.post(
      Uri.parse('$_baseUrl/expenses/batch'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items}),
    );

    _checkAuth(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to batch sync expenses to server');
    }
  }

  Future<void> deleteExpense(String token, String expenseId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/expenses/$expenseId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    _checkAuth(response);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete expense from server');
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkAuth(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> deleteAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          jsonDecode(response.body)['error'] ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      debugPrint('deleteAccount exception: $e');
    }
  }
}
