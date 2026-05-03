import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'user_session.dart'; // 1. IMPORT UserSession để lấy ID thật

class CartService {
  static ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/klever_fruits_api';
    } else {
      return 'http://10.0.2.2:8080/klever_fruits_api';
    }
  }

  // Hàm bổ trợ để lấy ID người dùng hiện tại dưới dạng String
  static String get _currentUserId => UserSession.userId?.toString() ?? '0';

  // 1. Tải lại tổng số lượng sản phẩm (Badge icon)
  static Future<void> refreshCartCount() async {
    if (!UserSession.isLoggedIn) {
      cartCountNotifier.value = 0;
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_cart.php?user_id=$_currentUserId'), // DÙNG ID THẬT
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

  // 2. Lấy danh sách sản phẩm trong giỏ hàng
  static Future<List<dynamic>> getCart() async {
    if (!UserSession.isLoggedIn) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_cart.php?user_id=$_currentUserId'), // DÙNG ID THẬT
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

  // 3. Thêm mới sản phẩm
  static Future<bool> addToCart(dynamic product) async {
    if (!UserSession.isLoggedIn) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_to_cart.php'),
        body: {
          'user_id': _currentUserId, // DÙNG ID THẬT
          'product_id': product['id'].toString(),
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

  // 4. Cập nhật số lượng
  static Future<bool> updateQuantity(int productId, int newQty) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_to_cart.php'),
        body: {
          'user_id': _currentUserId, // DÙNG ID THẬT
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
      debugPrint("Lỗi updateQuantity: $e");
    }
    return false;
  }

  // 5. XÓA 1 SẢN PHẨM LẺ
  static Future<bool> removeFromCart(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_product.php'),
        body: {
          'user_id': _currentUserId, // DÙNG ID THẬT
          'product_id': productId.toString(),
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await refreshCartCount();
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi kết nối delete_product.php: $e");
    }
    return false;
  }

  // 6. Xóa sạch giỏ hàng
  static Future<bool> clearCart() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clear_cart.php'),
        body: {'user_id': _currentUserId}, // DÙNG ID THẬT
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        cartCountNotifier.value = 0;
        return true;
      }
    } catch (e) {
      debugPrint("Lỗi clearCart: $e");
    }
    return false;
  }
}