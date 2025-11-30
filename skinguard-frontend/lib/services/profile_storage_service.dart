import 'package:shared_preferences/shared_preferences.dart';

/// Service class for handling profile data storage locally
class ProfileStorageService {
  static const String _keyFirstName = 'profile_first_name';
  static const String _keyLastName = 'profile_last_name';
  static const String _keyAge = 'profile_age';
  static const String _keyEmail = 'profile_email';
  static const String _keyPhone = 'profile_phone';

  /// Saves profile data to local storage
  Future<bool> saveProfile({
    String? firstName,
    String? lastName,
    String? age,
    String? email,
    String? phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (firstName != null && firstName.isNotEmpty) {
        await prefs.setString(_keyFirstName, firstName);
      } else {
        await prefs.remove(_keyFirstName);
      }
      
      if (lastName != null && lastName.isNotEmpty) {
        await prefs.setString(_keyLastName, lastName);
      } else {
        await prefs.remove(_keyLastName);
      }
      
      if (age != null && age.isNotEmpty) {
        await prefs.setString(_keyAge, age);
      } else {
        await prefs.remove(_keyAge);
      }
      
      if (email != null && email.isNotEmpty) {
        await prefs.setString(_keyEmail, email);
      } else {
        await prefs.remove(_keyEmail);
      }
      
      if (phone != null && phone.isNotEmpty) {
        await prefs.setString(_keyPhone, phone);
      } else {
        await prefs.remove(_keyPhone);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Loads profile data from local storage
  Future<Map<String, String?>> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'firstName': prefs.getString(_keyFirstName),
        'lastName': prefs.getString(_keyLastName),
        'age': prefs.getString(_keyAge),
        'email': prefs.getString(_keyEmail),
        'phone': prefs.getString(_keyPhone),
      };
    } catch (e) {
      return {
        'firstName': null,
        'lastName': null,
        'age': null,
        'email': null,
        'phone': null,
      };
    }
  }

  /// Clears all profile data
  Future<bool> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyFirstName);
      await prefs.remove(_keyLastName);
      await prefs.remove(_keyAge);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPhone);
      return true;
    } catch (e) {
      return false;
    }
  }
}



