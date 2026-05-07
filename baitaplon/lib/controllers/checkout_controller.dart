import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../services/cart_service.dart';

class CheckoutController {
  final String apiUrl = 'http://localhost:8080/klever_fruits_api/checkout.php';

  Future<Map<String, dynamic>> processOrder(OrderModel order) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: order.toMap(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await CartService.clearCart();
          return {"success": true, "orderId": order.orderId};
        }
        return {"success": false, "message": data['message'] ?? "Lỗi lưu đơn"};
      }
      return {"success": false, "message": "Lỗi kết nối (Code: ${response.statusCode})"};
    } catch (e) {
      return {"success": false, "message": "Không thể kết nối đến máy chủ XAMPP"};
    }
  }
}
