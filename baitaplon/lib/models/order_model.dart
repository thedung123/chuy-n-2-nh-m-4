class OrderModel {
  final String orderId;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String paymentMethod;
  final double totalAmount;
  final String status;
  final String? createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.totalAmount,
    required this.status,
    this.createdAt,
  });

  // Chuyển đổi sang Map để gửi dữ liệu lên Server (Checkout)
  Map<String, String> toMap() {
    return {
      "order_id": orderId,
      "user_id": userId,
      "name": name,
      "phone": phone,
      "address": address,
      "payment_method": paymentMethod,
      "total_amount": totalAmount.toString(),
      "status": status,
    };
  }

  // Chuyển đổi từ JSON nhận được từ Server về Model (Lịch sử đơn hàng)
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      // Đảm bảo các thông tin người nhận không bị null khi hiển thị
      name: json['name']?.toString() ?? 'N/A',
      phone: json['phone']?.toString() ?? 'N/A',
      address: json['address']?.toString() ?? 'N/A',
      paymentMethod: json['payment_method']?.toString() ?? 'N/A',
      // Xử lý an toàn cho kiểu số thực (tránh lỗi String/Double từ PHP)
      totalAmount: _parseDouble(json['total_amount']),
      status: json['status']?.toString() ?? 'Đang xử lý',
      createdAt: json['created_at']?.toString(),
    );
  }

  // Hàm bổ trợ xử lý dữ liệu số từ API một cách linh hoạt
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}