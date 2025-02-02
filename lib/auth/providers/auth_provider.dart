import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SharedPreferences _prefs;

  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _userData;

  AuthProvider(this._prefs) {
    _loadStoredData();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;

  // Cargar datos almacenados
  void _loadStoredData() {
    _token = _prefs.getString('token');
    final userDataString = _prefs.getString('userData');
    if (userDataString != null) {
      try {
        _userData = Map<String, dynamic>.from(json.decode(userDataString));
      } catch (e) {
        debugPrint('Error al decodificar userData: $e');
        _userData = null;
      }
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      _token = response['token'];
      _userData = response['user'];

      // Guardar en SharedPreferences
      await _prefs.setString('token', _token!);
      await _prefs.setString('userData', json.encode(_userData));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Registro de empresa
  Future<String> registerEmpresa({
    required String nombreEmpresa,
    required String rut,
    required String direccion,
    required String telefono,
    required String emailEmpresa,
    required String nombreAdmin,
    required String emailAdmin,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.registerEmpresa(
        nombreEmpresa: nombreEmpresa,
        rut: rut, // RUC
        direccion: direccion,
        telefono: telefono,
        emailEmpresa: emailEmpresa,
        nombreAdmin: nombreAdmin,
        emailAdmin: emailAdmin,
        username: username,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      return response['codigo_invitacion'];
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Registro de invitado
  Future<void> registerInvitado({
    required String codigoInvitacion,
    required String nombre,
    required String email,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.registerInvitado(
        codigoInvitacion: codigoInvitacion,
        nombre: nombre,
        email: email,
        username: username,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _userData = null;
    await _prefs.remove('token');
    await _prefs.remove('userData');
    notifyListeners();
  }

  // Verificar si el usuario está autenticado
  bool checkAuth() {
    return _token != null;
  }

  // Obtener rol del usuario
  int? getUserRole() {
    return _userData?['rol'];
  }

  // Obtener nombre de la empresa
  String? getEmpresaNombre() {
    return _userData?['empresa'];
  }
}
