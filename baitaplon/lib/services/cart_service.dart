import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../user_session.dart';

class CartService {
  static ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  static String get baseUrl {
    // Port 8080 khớp với cấu hình hiện tại của bạn
    if (kIsWeb) {
      return 'http://localhost:8080/klever_fruits_api';
    } else {
      return 'http://10.0.2.2:8080/klever_fruits_api';
    }
  }

  static String get _currentUserId => UserSession.userId?.toString() ?? '0';

  // --- HÀM THỰC THI THÊM VÀO GIỎ ---
  static Future<bool> addToCart(dynamic product) async {
    if (!UserSession.isLoggedIn) return false;

    try {
      String productId = (product is Map) ? product['id'].toString() : product.id.toString();

      final response = await http.post(
        Uri.parse('$baseUrl/add_to_cart.php'),
        body: {
          'user_id': _currentUserId,
          'product_id': productId,
          'quantity': '1',
          'action': 'add'
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await refreshCartCount();
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi addToCart: $e");
    }
    return false;
  }

  static Future<void> refreshCartCount() async {
    if (!UserSession.isLoggedIn) {
      cartCountNotifier.value = 0;
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_cart.php?user_id=$_currentUserId'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int total = 0;
        if (data is List) {
          for (var item in data) {
            total += int.tryParse(item['quantity'].toString()) ?? 0;
          }
        }
        cartCountNotifier.value = total;
      }
    } catch (e) {
      debugPrint("Lỗi refreshCartCount: $e");
    }
  }

  static Future<List<dynamic>> getCart() async {
    if (!UserSession.isLoggedIn) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_cart.php?user_id=$_currentUserId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          int total = 0;
          for (var item in data) {
            total += int.tryParse(item['quantity'].toString()) ?? 0;
          }
          cartCountNotifier.value = total;
          return data;
        }
      }
    } catch (e) {
      debugPrint("Lỗi getCart: $e");
    }
    return [];
  }

  static Future<bool> updateQuantity(int productId, int newQty) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_to_cart.php'),
        body: {
          'user_id': _currentUserId,
          'product_id': productId.toString(),
          'quantity': newQty.toString(),
          'action': 'update'
        },
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        await refreshCartCount();
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  // --- HÀM XÓA ĐÃ ĐƯỢC SỬA LẠI KHỚP VỚI PHP ---
  static Future<bool> removeFromCart(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_product.php'),
        body: {
          // Gửi 'id' thay vì 'product_id' để khớp với $_POST['id'] trong PHP của bạn
          'id': productId.toString(),
          'user_id': _currentUserId,
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Kiểm tra xem server có thực sự trả về success không
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          await refreshCartCount();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Lỗi removeFromCart: $e");
      return false;
    }
    return false;
  }

  static Future<bool> clearCart() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clear_cart.php'),
        body: {'user_id': _currentUserId},
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        cartCountNotifier.value = 0;
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}