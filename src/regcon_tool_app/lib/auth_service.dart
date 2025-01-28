import 'package:dio/dio.dart';
import 'shared_prefs.dart';

class AuthService {
  static const String _baseUrl = 'https://recgonback-8awa0rdv.b4a.run';
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  /// **LOGIN**: Método para iniciar sesión y guardar el token
  static Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/user-login',
        data: {'email': email, 'password': password},
      );

      print('Respuesta de la API: ${response.data}'); // Log para depuración

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        // Verificar si existe un token en la respuesta
        if (responseData.containsKey('token')) {
          await SharedPrefs.saveToken(responseData['token']);
          return true;
        } else {
          throw Exception('Error: No se recibió un token');
        }
      } else {
        throw Exception(response.data['error'] ?? 'Error en el login');
      }
    } on DioException catch (e) {
      print('Error en AuthService.login: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data['error'] ?? 'Error al iniciar sesión');
    }
  }

  /// **REGISTER**: Método para registrar un usuario
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String birthday,
  }) async {
    final Map<String, dynamic> requestData = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'registration_date': DateTime.now().toIso8601String(),
      'birthday': birthday,
    };

    print('📤 Enviando datos de registro: $requestData'); // LOG PARA DEPURACIÓN

    try {
      final response = await _dio.post('/users', data: requestData);
      print('✅ Respuesta de la API (Registro): ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response.data;
      } else {
        print('⚠️ Error inesperado: ${response.statusCode} - ${response.data}');
        throw Exception(
            response.data['error'] ?? 'Error desconocido en el registro');
      }
    } on DioException catch (e) {
      print(
          '❌ Error en AuthService.register: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data['error'] ?? 'Error en el registro');
    }
  }

  /// **VALIDACIÓN DE TOKEN**: Verifica si hay un token guardado
  static Future<bool> validateToken() async {
    try {
      final token = await SharedPrefs.getToken();
      return token != null;
    } catch (e) {
      print('Error en AuthService.validateToken: $e');
      return false;
    }
  }

  /// **CERRAR SESIÓN**: Elimina los datos guardados en `SharedPrefs`
  static Future<void> logout() async {
    await SharedPrefs.clear();
  }
}
