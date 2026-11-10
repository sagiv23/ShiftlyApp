import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String msg = 'Login failed';
      try {
        final body = jsonDecode(response.body);
        msg = body['error'] ?? body['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
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

  Future<Map<String, dynamic>> updateUserSettings(
    String token, {
    List<Map<String, dynamic>>? automaticExpenses,
    List<Map<String, dynamic>>? automaticIncomes,
    bool? automaticExpenseEnabled,
    bool? automaticIncomeEnabled,
  }) async {
    final body = <String, dynamic>{};
    if (automaticExpenses != null) {
      body['automaticExpenses'] = automaticExpenses;
    }
    if (automaticIncomes != null) body['automaticIncomes'] = automaticIncomes;
    if (automaticExpenseEnabled != null) {
      body['automaticExpenseEnabled'] = automaticExpenseEnabled;
    }
    if (automaticIncomeEnabled != null) {
      body['automaticIncomeEnabled'] = automaticIncomeEnabled;
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/auth/settings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    _checkAuth(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update settings on server');
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

  // --- Default Automatic Items Methods ---

  Future<List<dynamic>> getAutomaticItems(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/automatic-items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkAuth(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load automatic items from server');
    }
  }

  Future<void> batchUpsertAutomaticItems(
    String token,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/automatic-items/batch'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items}),
    );

    _checkAuth(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to sync automatic items to server');
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
      if (kDebugMode) {
        debugPrint('deleteAccount exception: ${e.runtimeType}');
      }
    }
  }

  // --- Secret Easter Egg Table API ---

  static const String _defaultSecretBlobUrl =
      'https://jsonblob.com/api/jsonBlob/1337448899220011999';

  Future<String> _getSecretBlobUrl() async {
    try {
      final box = Hive.box<dynamic>('settings');
      final storedUrl = box.get('secret_table_blob_url') as String?;
      if (storedUrl != null && storedUrl.isNotEmpty) {
        return storedUrl;
      }
    } catch (_) {}
    return _defaultSecretBlobUrl;
  }

  Future<Map<String, List<String>>?> getSecretTable() async {
    // 1. Try primary server endpoint
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/secret-table'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final proList =
            (data['pro'] as List?)?.map((e) {
              if (e is Map) return (e['name'] ?? e.toString()).toString();
              return e.toString();
            }).toList() ??
            [];
        final antiList =
            (data['anti'] as List?)?.map((e) => e.toString()).toList() ?? [];
        return {'pro': proList, 'anti': antiList};
      }
    } catch (_) {}

    // 2. Fallback to shared cloud JSONBlob store
    try {
      final blobUrl = await _getSecretBlobUrl();
      final response = await http
          .get(
            Uri.parse(blobUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final proList =
            (data['pro'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final antiList =
            (data['anti'] as List?)?.map((e) => e.toString()).toList() ?? [];
        return {'pro': proList, 'anti': antiList};
      } else if (response.statusCode == 404) {
        return await _createNewSecretBlob();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getSecretTable public store exception: $e');
      }
    }

    return null;
  }

  Future<Map<String, List<String>>?> _createNewSecretBlob() async {
    try {
      final createResponse = await http
          .post(
            Uri.parse('https://jsonblob.com/api/jsonBlob'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'pro': <String>[], 'anti': <String>[]}),
          )
          .timeout(const Duration(seconds: 5));

      if (createResponse.statusCode == 201) {
        final location = createResponse.headers['location'];
        if (location != null && location.isNotEmpty) {
          try {
            final box = Hive.box<dynamic>('settings');
            await box.put('secret_table_blob_url', location);
          } catch (_) {}
        }
        return {'pro': [], 'anti': []};
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateSecretTable(
    List<String> pro,
    List<String> anti, {
    String? token,
  }) async {
    bool updated = false;

    // 1. Try primary server endpoint
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http
          .post(
            Uri.parse('$_baseUrl/secret-table'),
            headers: headers,
            body: jsonEncode({'pro': pro, 'anti': anti}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        updated = true;
      }
    } catch (_) {}

    // 2. Also update shared cloud JSONBlob store
    try {
      final blobUrl = await _getSecretBlobUrl();
      final response = await http
          .put(
            Uri.parse(blobUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'pro': pro, 'anti': anti}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 404) {
        final createResponse = await http
            .post(
              Uri.parse('https://jsonblob.com/api/jsonBlob'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({'pro': pro, 'anti': anti}),
            )
            .timeout(const Duration(seconds: 5));

        if (createResponse.statusCode == 201) {
          final location = createResponse.headers['location'];
          if (location != null && location.isNotEmpty) {
            try {
              final box = Hive.box<dynamic>('settings');
              await box.put('secret_table_blob_url', location);
            } catch (_) {}
          }
          updated = true;
        }
      } else if (response.statusCode == 200) {
        updated = true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('updateSecretTable public store exception: $e');
      }
    }

    return updated;
  }
}
