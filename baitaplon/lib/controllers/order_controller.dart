import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class OrderController {
  // Đường dẫn API kết nối đến file PHP trên XAMPP
  final String apiUrl = 'http://localhost:8080/klever_fruits_api/get_order_history.php';

  Future<List<OrderModel>> fetchMyOrders() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Chuyển đổi từng phần tử JSON sang OrderModel sử dụng hàm fromJson bạn vừa cập nhật
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        print("Lỗi phản hồi từ Server: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối OrderController: $e");
    }
    return [];
  }
}