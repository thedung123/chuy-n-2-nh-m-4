import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // Đảm bảo URL này chính xác với cấu hình của bạn
  final String apiUrl = 'http://localhost:8080/klever_fruits_api';

  // Hàm lấy lịch sử đơn hàng từ file PHP mới tạo
  Future<List<dynamic>> fetchMyOrders() async {
    try {
      // Đã đổi sang file get_order_history.php để đồng bộ
      final response = await http.get(Uri.parse('$apiUrl/get_order_history.php'));

      if (response.statusCode == 200) {
        // Dữ liệu trả về từ PHP đã được sắp xếp DESC (mới nhất lên đầu)
        return jsonDecode(response.body);
      } else {
        debugPrint("Lỗi Server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi kết nối API: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Màu nền nhẹ cho chuyên nghiệp
      appBar: AppBar(
        title: const Text("Lịch sử mua hàng",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              // Làm mới danh sách khi nhấn nút
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        // Gọi hàm fetch mỗi khi UI cần render lại
        future: fetchMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Có lỗi xảy ra khi tải dữ liệu"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("Bạn chưa có đơn hàng nào.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                // Logic màu sắc trạng thái đồng bộ với Admin
                Color statusColor;
                switch (order['status']) {
                  case "Đang xử lý": statusColor = Colors.grey; break;
                  case "Đang đóng gói": statusColor = Colors.blue; break;
                  case "Đang giao hàng": statusColor = Colors.orange; break;
                  case "Đã giao hàng": statusColor = Colors.green; break;
                  case "Đã hủy": statusColor = Colors.red; break;
                  default: statusColor = Colors.black54;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text("Mã đơn: ${order['order_id']}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text("${order['created_at']}"),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("${order['total_amount']}đ",
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        border: Border.all(color: statusColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order['status'] ?? "N/A",
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      _showOrderStatusDetail(context, order['order_id'], order['status'] ?? "Đang xử lý");
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showOrderStatusDetail(BuildContext context, String orderId, String status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Chi tiết trạng thái", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(orderId, style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w500)),
              const Divider(height: 40),

              _buildStatusTimeline(status),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Đã hiểu", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTimeline(String status) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
          child: Icon(_getStatusIcon(status), color: const Color(0xFF2E7D32), size: 30),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(_getStatusDescription(status), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Đang xử lý": return Icons.hourglass_empty;
      case "Đang đóng gói": return Icons.inventory_2_outlined;
      case "Đang giao hàng": return Icons.local_shipping_outlined;
      case "Đã giao hàng": return Icons.check_circle_outline;
      case "Đã hủy": return Icons.cancel_outlined;
      default: return Icons.info_outline;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case "Đang xử lý": return "Hệ thống đã nhận đơn và đang chờ xác nhận.";
      case "Đang đóng gói": return "Chúng tôi đang lựa chọn những trái cây tươi ngon nhất cho bạn.";
      case "Đang giao hàng": return "Shipper đang mang sản phẩm đến địa chỉ của bạn.";
      case "Đã giao hàng": return "Đơn hàng đã hoàn tất. Chúc bạn ngon miệng!";
      case "Đã hủy": return "Rất tiếc, đơn hàng đã bị hủy bỏ.";
      default: return "Đang cập nhật thông tin...";
    }
  }
}