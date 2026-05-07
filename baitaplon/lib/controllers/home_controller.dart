import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../services/cart_service.dart';

class HomeController {
  final Map<String, String> categoryMap = {
    "Trái Cây Nội Địa": "noi_dia",
    "Trái cây nhập khẩu": "nhap_khau",
    "Rau sạch": "rau_sach",
    "Combo Quà Tặng": "combo",
  };

  Future<List<Product>> fetchProducts(String selectedCategory, String searchKeyword) async {
    try {
      String url;
      if (searchKeyword.isNotEmpty) {
        url = '${CartService.baseUrl}/search_products.php?query=${Uri.encodeComponent(searchKeyword.trim())}';
      } else {
        String categoryId = categoryMap[selectedCategory] ?? "noi_dia";
        url = '${CartService.baseUrl}/get_products.php?category=$categoryId';
      }

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      }
      throw Exception('Server Error');
    } catch (e) {
      throw Exception('Connection Error');
    }
  }
}
