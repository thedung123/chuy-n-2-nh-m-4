import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'cart_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // 1. Tải dữ liệu giỏ hàng từ API
  Future<void> _loadCart() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final items = await CartService.getCart();
      if (mounted) {
        setState(() {
          cartItems = items.map((item) {
            final Map<String, dynamic> mutableItem = Map<String, dynamic>.from(item);
            mutableItem['quantity'] = int.tryParse(item['quantity'].toString()) ?? 1;
            return mutableItem;
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Lỗi load cart: $e");
    }
  }

  // 2. Cập nhật số lượng và FIX TRIỆT ĐỂ LỖI XÓA LẺ
  Future<void> _updateQuantity(int index, int delta) async {
    final item = cartItems[index];

    // Lấy ID: Ưu tiên product_id, nếu không có thì lấy id
    final dynamic rawId = item['product_id'] ?? item['id'];
    if (rawId == null) return;

    final int productId = int.parse(rawId.toString());
    int currentQty = item['quantity'] ?? 1;
    int newQty = currentQty + delta;

    if (newQty > 0) {
      // Tăng giảm số lượng bình thường
      setState(() => cartItems[index]['quantity'] = newQty);
      await CartService.updateQuantity(productId, newQty);
    } else {
      // Khi số lượng về 0 -> Hiện thông báo xác nhận xóa lẻ
      bool? confirm = await _showSingleDeleteConfirm(item['name']);

      if (confirm == true) {
        // A. Xóa trên giao diện ngay lập tức cho mượt
        setState(() {
          cartItems.removeAt(index);
        });

        // B. Gọi API xóa và phải đợi (await) kết quả thực tế từ DB
        try {
          bool success = await CartService.removeFromCart(productId);

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Đã gỡ ${item['name']} khỏi giỏ hàng")),
            );
          } else {
            // Nếu DB chưa xóa được, tải lại để hiện lại sản phẩm tránh mất dữ liệu ảo
            _loadCart();
          }
        } catch (e) {
          _loadCart();
        }

        // C. Tải lại giỏ hàng để cập nhật tổng tiền thanh toán
        _loadCart();
      }
    }
  }

  double _calculateTotal() {
    return cartItems.fold(0, (sum, item) {
      double price = double.tryParse(item['price'].toString()) ?? 0;
      int qty = item['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Giỏ hàng của bạn",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                if (await _showDeleteConfirm() == true) {
                  setState(() => cartItems = []);
                  await CartService.clearCart();
                  _loadCart();
                }
              },
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: cartItems.length,
            itemBuilder: (context, index) => _buildCartItem(index),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildCartItem(int index) {
    final item = cartItems[index];
    final double price = double.tryParse(item['price'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Cập nhật withValues theo chuẩn mới
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              item['image_url'] ?? '',
              width: 80, height: 80, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Sản phẩm',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(currencyFormat.format(price),
                    style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildQuantityControl(index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(int index) {
    return Row(
      children: [
        _qtyBtn(Icons.remove, () => _updateQuantity(index, -1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text("${cartItems[index]['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        _qtyBtn(Icons.add, () => _updateQuantity(index, 1), isPrimary: true),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF2E7D32) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: isPrimary ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tổng cộng", style: TextStyle(color: Colors.grey)),
              Text(currencyFormat.format(_calculateTotal()),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              if (cartItems.isNotEmpty) {
                await Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CheckoutScreen(cartItems: cartItems, totalAmount: _calculateTotal())
                ));
                _loadCart();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("THANH TOÁN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const Text("Giỏ hàng trống", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- PHẦN DIALOG XÁC NHẬN ---
  Future<bool?> _showSingleDeleteConfirm(String name) {
    return _showDialog("Xác nhận gỡ", "Bạn muốn xóa '$name' khỏi giỏ hàng?");
  }

  Future<bool?> _showDeleteConfirm() {
    return _showDialog("Xóa tất cả", "Dọn sạch giỏ hàng của bạn?");
  }

  Future<bool?> _showDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("HỦY")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("ĐỒNG Ý", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}