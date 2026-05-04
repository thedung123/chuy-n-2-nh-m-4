import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/san_pham_model.dart';

class AdminController {
  final String apiUrl = 'http://localhost:8080/klever_fruits_api';

  Future<Map<String, dynamic>> fetchAdminStats() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/get_admin_stats.php'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      return {"revenue": "0đ", "orders": "0", "products": "0", "customers": "0"};
    }
    return {"revenue": "0đ", "orders": "0", "products": "0", "customers": "0"};
  }

  Future<List<SanPham>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/get_products.php'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => SanPham.fromJson(item)).toList();
      }
    } catch (e) {
      print("Lỗi tải sản phẩm: $e");
    }
    return [];
  }

  Future<List<dynamic>> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/get_all_orders.php'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print("Lỗi tải đơn hàng: $e");
    }
    return [];
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/update_order_status.php'),
        body: {'order_id': orderId, 'status': newStatus},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final response = await http.post(Uri.parse('$apiUrl/delete_product.php'), body: {'id': id});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveProduct(String? id, String name, String price, String img) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/save_product.php'),
        body: {'id': id ?? '', 'name': name, 'price': price, 'image_url': img},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}