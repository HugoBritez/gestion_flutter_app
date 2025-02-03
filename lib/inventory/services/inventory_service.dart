import 'package:dio/dio.dart';
import '../models/articulo.dart';

class InventoryService {
  final Dio _dio;
  final String token;
  
  InventoryService({
    required String baseUrl,
    required this.token,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,

            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => status! < 500,
          ),
        );

  Future<List<Article>> getArticles({String? search}) async {
    try {
      final response = await _dio.get(
        '/inventario/articulos',
        queryParameters: search != null ? {'nombre': search} : null,
      );

      // Verificar el código de estado
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 200) {
        throw Exception(
          response.data['error'] ?? 'Error al obtener los artículos',
        );
      }

      return (response.data as List)
          .map((json) => Article.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado');
      }
      throw Exception(
        e.response?.data?['error'] ?? 'Error al obtener los artículos',
      );
    } catch (e) {
      throw Exception('Error al obtener los artículos: ${e.toString()}');
    }
  }

  Future<void> createArticle(Map<String, dynamic> articleData) async {
    try {
      final response = await _dio.post(
        '/inventario/articulos',
        data: articleData,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 201) {
        throw Exception(
          response.data['error'] ?? 'Error al crear el artículo',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado');
      }
      throw Exception(
        e.response?.data?['error'] ?? 'Error al crear el artículo',
      );
    }
  }

  Future<void> createBatch(
      int articleId, Map<String, dynamic> batchData) async {
    try {
      final response = await _dio.post(
        '/inventario/lotes',
        data: {
          'articulo_id': articleId,
          ...batchData,
        },
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 201) {
        throw Exception(
          response.data['error'] ?? 'Error al crear el lote',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado');
      }
      throw Exception(
        e.response?.data?['error'] ?? 'Error al crear el lote',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getBatches(int articleId) async {
    try {
      final response = await _dio.get(
        '/inventario/lotes',
        queryParameters: {'articulo_id': articleId},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 200) {
        throw Exception(
          response.data['error'] ?? 'Error al obtener los lotes',
        );
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado');
      }
      throw Exception(
        e.response?.data?['error'] ?? 'Error al obtener los lotes',
      );
    }
  }


  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('/categorias');

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 200) {
        throw Exception(
          response.data['error'] ?? 'Error al obtener las categorías',
        );
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado');
      }
      throw Exception(
        e.response?.data?['error'] ?? 'Error al obtener las categorías',
      );
    }
  }
Future<List<Map<String, dynamic>>> getDeposits({String? nombre}) async {
    try {
      print('Obteniendo depósitos...'); // Debug
      final response = await _dio.get('/depositos');

      print(
          'Token usado: ${_dio.options.headers['Authorization']}'); // Debug del token
      print('Respuesta completa: ${response.data}'); // Debug de la respuesta

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 200) {
        throw Exception(
          response.data['error'] ?? 'Error al obtener los depósitos',
        );
      }

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error obteniendo depósitos: $e');
      rethrow;
    }
  }

    Future<Map<String, dynamic>> createDeposit({
    required String nombre,
    required String direccion,
  }) async {
    try {
      final response = await _dio.post(
        '/depositos',
        data: {
          'nombre': nombre,
          'direccion': direccion,
        },
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 201) {
        throw Exception(
          response.data['error'] ?? 'Error al crear el depósito',
        );
      }

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado');
      }
      throw Exception(
        e.response?.data?['error'] ?? 'Error al crear el depósito',
      );
    }
  }

    Future<List<Map<String, dynamic>>> getDepositInventory(int depositId) async {
    try {
      final response = await _dio.get(
        '/depositos/inventario',
        queryParameters: {'id': depositId},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 200) {
        throw Exception(
          response.data['error'] ??
              'Error al obtener el inventario del depósito',
        );
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado');
      }
      throw Exception(
        e.response?.data?['error'] ??
            'Error al obtener el inventario del depósito',
      );
    }
  }

    Future<void> updateDeposit({
    required int id,
    required String nombre,
    required String direccion,
  }) async {
    try {
      final response = await _dio.put(
        '/depositos',
        queryParameters: {'id': id},
        data: {
          'nombre': nombre,
          'direccion': direccion,
        },
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      }

      if (response.statusCode != 200) {
        throw Exception(
          response.data['error'] ?? 'Error al actualizar el depósito',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado');
      }
      throw Exception(
        e.response?.data?['error'] ?? 'Error al actualizar el depósito',
      );
    }
  }


}
