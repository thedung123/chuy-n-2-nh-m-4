import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  // Đảm bảo URL này khớp với cấu hình XAMPP của bạn
  final String apiUrl = 'http://localhost:8080/klever_fruits_api';

  // Biến lưu trữ Future để quản lý việc tải dữ liệu đơn hàng
  Future<List<dynamic>>? _ordersFuture;

  // Màu sắc chủ đạo
  static const Color sidebarBg = Color(0xFF0D1B2A);
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color bgGrey = Color(0xFFF4F7F6);

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Thống kê', 'icon': Icons.grid_view_rounded},
    {'title': 'Sản phẩm', 'icon': Icons.apple_rounded},
    {'title': 'Đơn hàng', 'icon': Icons.receipt_long_rounded},
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo lấy dữ liệu đơn hàng ngay khi vào trang
    _ordersFuture = fetchOrders();
  }

  // --- LOGIC API ---

  Future<Map<String, dynamic>> fetchAdminStats() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/get_admin_stats.php'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Lỗi thống kê: $e");
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
      debugPrint("Lỗi tải sản phẩm: $e");
    }
    return [];
  }

  Future<List<dynamic>> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/get_all_orders.php'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Lỗi tải đơn hàng: $e");
    }
    return [];
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/update_order_status.php'),
        body: {'order_id': orderId, 'status': newStatus},
      );
      if (response.statusCode == 200) {
        // Cập nhật lại Future để FutureBuilder tải lại dữ liệu mới nhất
        setState(() {
          _ordersFuture = fetchOrders();
        });
        _showSnackBar("Đã cập nhật đơn $orderId thành $newStatus!");
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối server khi duyệt đơn");
    }
  }

  Future<void> _deleteProduct(String id) async {
    try {
      await http.post(Uri.parse('$apiUrl/delete_product.php'), body: {'id': id});
      setState(() {});
      _showSnackBar("Đã xóa sản phẩm thành công");
    } catch (e) {
      _showSnackBar("Lỗi khi xóa sản phẩm");
    }
  }

  Future<void> _saveProduct(String? id, String name, String price, String img) async {
    try {
      await http.post(
        Uri.parse('$apiUrl/save_product.php'),
        body: {'id': id ?? '', 'name': name, 'price': price, 'image_url': img},
      );
      setState(() {});
      _showSnackBar("Lưu dữ liệu thành công!");
    } catch (e) {
      _showSnackBar("Lỗi kết nối server");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- GIAO DIỆN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(child: _buildBodyContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0: return _buildDashboard();
      case 1: return _buildProductList();
      case 2: return _buildOrderList();
      default: return const Center(child: Text("Tính năng đang phát triển"));
    }
  }

  Widget _buildOrderList() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quản lý & Duyệt đơn hàng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Chưa có đơn hàng nào"));
                }

                final orders = snapshot.data!;
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    // Danh sách trạng thái chuẩn khớp với Logic xử lý lỗi Dropdown
                    List<String> statusOptions = [
                      "Đang xử lý",
                      "Đang đóng gói",
                      "Đang giao hàng",
                      "Đã giao hàng",
                      "Đã hủy"
                    ];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.receipt, color: primaryGreen),
                        title: Text("Mã đơn: ${order['order_id']}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Tổng: ${order['total_amount']}đ\nNgày: ${order['created_at']}"),
                        trailing: DropdownButton<String>(
                          value: statusOptions.contains(order['status']) ? order['status'] : "Đang xử lý",
                          underline: const SizedBox(),
                          icon: const Icon(Icons.edit_location_alt, color: Colors.blue),
                          items: statusOptions.map((String s) {
                            return DropdownMenuItem<String>(
                                value: s,
                                child: Text(s, style: const TextStyle(fontSize: 13))
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            if (newVal != null && newVal != order['status']) {
                              _updateOrderStatus(order['order_id'], newVal);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC GIAO DIỆN PHỤ (SIDEBAR, DASHBOARD, PRODUCT LIST) ---

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: sidebarBg,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.admin_panel_settings, color: Colors.greenAccent, size: 50),
          const Text("KLEVER ADMIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: primaryGreen,
                  leading: Icon(_menuItems[index]['icon'], color: Colors.white),
                  title: Text(_menuItems[index]['title'], style: const TextStyle(color: Colors.white)),
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text("Thoát", style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(_menuItems[_selectedIndex]['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          const CircleAvatar(backgroundColor: primaryGreen, child: Icon(Icons.person, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchAdminStats(),
      builder: (context, snapshot) {
        var data = snapshot.data ?? {"revenue": "0đ", "orders": "0", "products": "0", "customers": "0"};
        return GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 4,
          crossAxisSpacing: 20,
          children: [
            _statCard("Doanh thu", data['revenue'], Icons.monetization_on, Colors.green),
            _statCard("Đơn hàng", data['orders'].toString(), Icons.shopping_cart, Colors.blue),
            _statCard("Sản phẩm", data['products'].toString(), Icons.apple, Colors.orange),
            _statCard("Khách hàng", data['customers'].toString(), Icons.people, Colors.purple),
          ],
        );
      },
    );
  }

  Widget _statCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Danh sách sản phẩm từ Database", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showProductForm(),
                icon: const Icon(Icons.add),
                label: const Text("Thêm mới"),
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white),
              )
            ],
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<SanPham>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final sp = snapshot.data![index];
                    return ListTile(
                      leading: Image.network(sp.imageUrl, width: 40, errorBuilder: (c,e,s) => const Icon(Icons.image)),
                      title: Text(sp.name),
                      subtitle: Text("${sp.price}đ"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showProductForm(product: sp)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProduct(sp.id)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProductForm({SanPham? product}) {
    final nameCtrl = TextEditingController(text: product?.name);
    final priceCtrl = TextEditingController(text: product?.price);
    final imgCtrl = TextEditingController(text: product?.imageUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? "Thêm sản phẩm" : "Sửa sản phẩm"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Giá")),
            TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: "Link ảnh")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              _saveProduct(product?.id, nameCtrl.text, priceCtrl.text, imgCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
}

class SanPham {
  final String id;
  final String name;
  final String price;
  final String imageUrl;

  SanPham({required this.id, required this.name, required this.price, required this.imageUrl});

  factory SanPham.fromJson(Map<String, dynamic> json) {
    return SanPham(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: json['price'].toString(),
      imageUrl: json['image_url'] ?? '',
    );
  }
}