import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<bool> isLoggedIn() async {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> login(String email) async {
    await _prefs.setBool('isLoggedIn', true);
    await _prefs.setString('userEmail', email);
  }

  Future<void> logout() async {
    await _prefs.remove('isLoggedIn');
    await _prefs.remove('userEmail');
  }
}

// Provider to inject SharedPreferences
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must override in main()');
});

// AuthService provider
final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return AuthService(prefs);
});

// Auth state provider (true if logged in, false otherwise)
final authStateProvider = FutureProvider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isLoggedIn();
});
