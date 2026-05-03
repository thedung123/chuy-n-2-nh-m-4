import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderWidget extends StatefulWidget {
  final VoidCallback onLogoTap;
  final VoidCallback onAccountTap;
  final VoidCallback onCartTap;
  final String? cartCount;
  // BƯỚC 1: Thêm tham số này để nhận hàm tìm kiếm từ MainScreen
  final Function(String) onSearch;

  const HeaderWidget({
    super.key,
    required this.onLogoTap,
    required this.onAccountTap,
    required this.onCartTap,
    required this.onSearch, // Thêm vào constructor
    this.cartCount,
  });

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGrey = Color(0xFFF5F5F7);
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 60),
          Expanded(child: _buildSearchBar()),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return InkWell(
      onTap: widget.onLogoTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco_rounded, color: primaryGreen, size: 40),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "LUÔN TƯƠI NGON",
              style: TextStyle(color: primaryGreen, fontSize: 9, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        // BƯỚC 2: Khi người dùng nhấn Enter (hoặc nút tìm kiếm trên bàn phím)
        onSubmitted: (value) {
          widget.onSearch(value);
        },
        // Hoặc tìm kiếm ngay khi đang gõ (nếu muốn):
        // onChanged: (value) => widget.onSearch(value),
        decoration: const InputDecoration(
          hintText: "Tìm kiếm trái cây sạch...",
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // Giữ lại các hàm cũ của bạn...
  Widget _buildActionItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    String? count,
    bool isHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              backgroundColor: Colors.redAccent,
              isLabelVisible: count != null && count != "0",
              label: Text(count ?? "", style: const TextStyle(fontSize: 10)),
              child: Icon(icon, size: 26, color: isHighlight ? primaryGreen : Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? primaryGreen : Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}