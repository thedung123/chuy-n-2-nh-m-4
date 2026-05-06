import 'package:flutter/material.dart';

class TopBarWidget extends StatefulWidget {
  final VoidCallback onHome;
  const TopBarWidget({super.key, required this.onHome});

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  String language = "VN";

  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentYellow = Color(0xFFFFD600);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      // Giảm padding để không bị tràn trên màn hình nhỏ
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: darkGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Khu vực khuyến mãi - Dùng Flexible để tự co ngắn text
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_shipping_outlined, color: accentYellow, size: 14),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    language == "VN"
                        ? "Giao hàng miễn phí cho đơn từ 500k"
                        : "Free delivery on orders over 500k",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 2. Khu vực các nút chức năng
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionLink(
                language == "VN" ? "Kênh Người Bán" : "Seller Centre",
                icon: Icons.storefront_outlined,
                onTap: () => Navigator.pushNamed(context, '/admin'),
              ),
              // Chỉ hiện "Hệ thống cửa hàng" khi màn hình đủ rộng (> 600px)
              if (MediaQuery.of(context).size.width > 600)
                _buildActionLink(
                  language == "VN" ? "Hệ thống cửa hàng" : "Store Locator",
                  icon: Icons.location_on_outlined,
                ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: VerticalDivider(color: Colors.white24, indent: 10, endIndent: 10),
          ),

          // 3. Khu vực Ngôn ngữ
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              ...["VN", "EN"].map((lang) => _buildLanguageButton(lang)).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionLink(String label, {required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String lang) {
    bool isSelected = language == lang;
    return InkWell(
      onTap: () => setState(() => language = lang),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          lang,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
