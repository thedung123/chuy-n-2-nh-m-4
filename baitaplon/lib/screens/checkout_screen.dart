import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_service.dart';
import 'user_session.dart';

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color kleverGreen = Color(0xFF2E7D32);
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  String _selectedPayment = "cod";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserSession.fullName ?? "");
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // HÀM XỬ LÝ ĐẶT HÀNG CHÍNH
  Future<void> _finishOrder(double finalTotal) async {
    // --- DÒNG KIỂM TRA (DEBUG) ---
    // Bạn hãy nhìn vào tab Debug Console ở dưới cùng VS Code khi bấm nút
    print("-----------------------------------------");
    print("KIỂM TRA SESSION TRƯỚC KHI GỬI:");
    print("User ID: ${UserSession.userId}");
    print("Full Name: ${UserSession.fullName}");
    print("-----------------------------------------");

    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin nhận hàng!"))
      );
      _showEditInfoDialog();
      return;
    }

    if (UserSession.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi: ID người dùng bị trống! Hãy đăng xuất và đăng nhập lại để nạp lại dữ liệu."))
      );
      return;
    }

    String orderId = "ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: kleverGreen)),
    );

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/klever_fruits_api/checkout.php'),
        body: {
          "order_id": orderId,
          "user_id": UserSession.userId.toString(),
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "address": _addressController.text.trim(),
          "payment_method": _selectedPayment == "bank" ? "Chuyển khoản VietQR" : "COD",
          "total_amount": finalTotal.toString(),
          "status": "Đang đóng gói",
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      Navigator.pop(context);

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        await CartService.clearCart();
        _showSuccessDialog(orderId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Lỗi lưu đơn hàng"))
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi kết nối Server! Vui lòng kiểm tra XAMPP (Port 8080) và CORS."))
      );
    }
  }

  void _showEditInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thông tin nhận hàng"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Họ và tên")),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Số điện thoại"), keyboardType: TextInputType.phone),
              TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Địa chỉ cụ thể")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("CẬP NHẬT"),
          ),
        ],
      ),
    );
  }

  void _showBankQR(double finalAmount) {
    String bankId = "TCB";
    String accountNo = "8226092004";
    String accountName = Uri.encodeComponent("TRAN TUNG DUONG");
    String description = Uri.encodeComponent("Thanh toan don hang Klever");
    String qrUrl = "https://img.vietqr.io/image/$bankId-$accountNo-compact2.png?amount=${finalAmount.toInt()}&addInfo=$description&accountName=$accountName";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Center(child: Text("Thanh toán VietQR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Chuyển tiền đến: TRAN TUNG DUONG"),
            const Text("STK: 8226 0920 04 - Techcombank"),
            const SizedBox(height: 10),
            Image.network(qrUrl, height: 220, width: 220),
            const SizedBox(height: 10),
            Text("Số tiền: ${currencyFormat.format(finalAmount)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          ElevatedButton(onPressed: () { Navigator.pop(context); _finishOrder(finalAmount); }, child: const Text("ĐÃ CHUYỂN KHOẢN")),
        ],
      ),
    );
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text("Đặt hàng thành công!\nMã đơn: $orderId\nTrạng thái: Đang đóng gói."),
        actions: [
          TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text("XÁC NHẬN")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double shippingFee = 30000;
    double finalTotal = widget.totalAmount + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán", style: TextStyle(color: Colors.white)),
        backgroundColor: kleverGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: "ĐỊA CHỈ NHẬN HÀNG"),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: kleverGreen),
                title: Text(_nameController.text.isEmpty ? "Chưa nhập tên" : "${_nameController.text} - ${_phoneController.text}"),
                subtitle: Text(_addressController.text.isEmpty ? "Nhấn icon bút để nhập địa chỉ" : _addressController.text),
                trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: _showEditInfoDialog),
              ),
            ),
            const SizedBox(height: 15),
            const _SectionTitle(title: "PHƯƠNG THỨC THANH TOÁN"),
            Card(
              child: Column(
                children: [
                  RadioListTile(
                    value: "cod", groupValue: _selectedPayment,
                    title: const Text("Thanh toán khi nhận hàng (COD)"),
                    onChanged: (v) => setState(() => _selectedPayment = v!),
                  ),
                  RadioListTile(
                    value: "bank", groupValue: _selectedPayment,
                    title: const Text("Chuyển khoản VietQR"),
                    onChanged: (v) => setState(() => _selectedPayment = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const _SectionTitle(title: "TÓM TẮT ĐƠN HÀNG"),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _rowSummary("Tiền hàng", currencyFormat.format(widget.totalAmount)),
                    _rowSummary("Phí vận chuyển", currencyFormat.format(shippingFee)),
                    const Divider(),
                    _rowSummary("Tổng cộng", currencyFormat.format(finalTotal), isBold: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kleverGreen, padding: const EdgeInsets.all(16)),
          onPressed: () => _selectedPayment == "bank" ? _showBankQR(finalTotal) : _finishOrder(finalTotal),
          child: const Text("XÁC NHẬN ĐẶT HÀNG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _rowSummary(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.red : Colors.black)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey));
  }
}