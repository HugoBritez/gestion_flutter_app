import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:8000'; // Ajusta esto

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['error'] ?? 'Error al iniciar sesión');
      }
      throw Exception('Error al iniciar sesión');
    }
  }

  // Registro de empresa
  Future<Map<String, dynamic>> registerEmpresa({
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
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register/empresa',
        data: {
          'empresa': {
            'nombre': nombreEmpresa,
            'rut': rut,
            'direccion': direccion,
            'telefono': telefono,
            'email': emailEmpresa,
          },
          'admin': {
            'nombre': nombreAdmin,
            'email': emailAdmin,
            'username': username,
            'password': password,
          },
        },
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['error'] ?? 'Error al registrar empresa');
      }
      throw Exception('Error al registrar empresa');
    }
  }

  // Registro de usuario invitado
  Future<Map<String, dynamic>> registerInvitado({
    required String codigoInvitacion,
    required String nombre,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register/invitado',
        data: {
          'codigo_invitacion': codigoInvitacion,
          'nombre': nombre,
          'email': email,
          'username': username,
          'password': password,
        },
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            e.response?.data['error'] ?? 'Error al registrar usuario');
      }
      throw Exception('Error al registrar usuario');
    }
  }
}
