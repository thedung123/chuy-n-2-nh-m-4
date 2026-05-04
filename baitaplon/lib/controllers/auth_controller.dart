import 'dart:convert';
import 'package:http/http.dart' as http;
import '../user_session.dart'; // Đảm bảo đúng đường dẫn file session của bạn

class AuthController {
  final String apiUrl = "http://localhost:8080/klever_fruits_api";

  // Hàm xử lý chung cho cả Login và Register
  Future<Map<String, dynamic>> handleAuth({
    required bool isLogin,
    required String username,
    required String password,
  }) async {
    try {
      final String fileName = isLogin ? 'login.php' : 'register.php';
      final url = Uri.parse("$apiUrl/$fileName");

      final response = await http.post(
        url,
        body: {"username": username, "password": password},
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // Lưu session nếu có thông tin user trả về
        if (data['user'] != null) {
          UserSession.setSession(data['user']);
        }
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': "Lỗi kết nối Server"};
    }
  }
}