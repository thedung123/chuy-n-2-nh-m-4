import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final dynamic product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final double price = double.tryParse(product['price'].toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Chi tiết sản phẩm'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product['image_url'] ?? '',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(height: 300, color: Colors.grey, child: const Icon(Icons.image_not_supported, size: 100)),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currencyFormat.format(price),
                    style: const TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text("Mô tả sản phẩm:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    product['description'] ?? 'Đang cập nhật nội dung...',
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context, product['name'] ?? 'Sản phẩm'),
    );
  }

  Widget _buildBottomAction(BuildContext context, String productName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đã thêm $productName vào giỏ hàng!")),
          );
        },
        child: const Text("THÊM VÀO GIỎ HÀNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
