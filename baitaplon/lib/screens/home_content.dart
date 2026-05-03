import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'product_detail_screen.dart';
import 'cart_service.dart';

class HomeContent extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final String searchKeyword;

  const HomeContent({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.searchKeyword = "",
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  static const Color kleverDark = Color(0xFF1B5E20);
  static const Color kleverMain = Color(0xFF2E7D32);
  static const Color kleverSoft = Color(0xFFF1F8E9);
  static const Color bgCanvas = Color(0xFFF9FBF9);

  final Map<String, String> categoryMap = {
    "Trái Cây Nội Địa": "noi_dia",
    "Trái cây nhập khẩu": "nhap_khau",
    "Rau sạch": "rau_sach",
    "Combo Quà Tặng": "combo",
  };

  @override
  void initState() {
    super.initState();
    CartService.getCart();
  }

  Future<List<dynamic>> fetchProducts() async {
    try {
      String url;
      if (widget.searchKeyword.isNotEmpty) {
        url = 'http://localhost:8080/klever_fruits_api/search_products.php?query=${Uri.encodeComponent(widget.searchKeyword.trim())}';
      } else {
        String categoryId = categoryMap[widget.selectedCategory] ?? "noi_dia";
        url = 'http://localhost:8080/klever_fruits_api/get_products.php?category=$categoryId';
      }

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Server Error');
    } catch (e) {
      throw Exception('Connection Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Colors.grey.shade100)),
          ),
          child: _buildModernSidebar(),
        ),
        Expanded(
          child: Container(
            color: bgCanvas,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                key: ValueKey(widget.selectedCategory + widget.searchKeyword),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.searchKeyword.isEmpty) _buildPremiumHero(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(),
                  const SizedBox(height: 15),
                  FutureBuilder<List<dynamic>>(
                    future: fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: kleverMain));
                      }
                      if (snapshot.hasError) return _buildErrorWidget(snapshot.error.toString());

                      final allProducts = snapshot.data ?? [];
                      if (allProducts.isEmpty) return _buildNoProductWidget();

                      // Logic lọc chính xác và gợi ý
                      List<dynamic> exactMatches = [];
                      List<dynamic> suggestions = [];

                      if (widget.searchKeyword.isNotEmpty) {
                        String query = widget.searchKeyword.toLowerCase();
                        for (var p in allProducts) {
                          String name = p['name'].toString().toLowerCase();
                          if (name.contains(query)) {
                            exactMatches.add(p);
                          } else {
                            suggestions.add(p);
                          }
                        }
                      } else {
                        exactMatches = allProducts;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phần 1: Kết quả tìm kiếm chính xác (Ví dụ: Chỉ hiện Táo)
                          if (exactMatches.isNotEmpty)
                            _buildProductGrid(exactMatches),

                          if (exactMatches.isEmpty && widget.searchKeyword.isNotEmpty)
                            const Text("Không tìm thấy kết quả khớp chính xác.",
                                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),

                          // Phần 2: Sản phẩm tương tự (Gợi ý)
                          if (widget.searchKeyword.isNotEmpty && suggestions.isNotEmpty) ...[
                            const SizedBox(height: 40),
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                "Sản phẩm tương tự có thể bạn thích",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ),
                            _buildProductGrid(suggestions.take(4).toList()), // Lấy 4 sản phẩm gợi ý
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Hàm xây dựng Grid dùng chung cho cả 2 phần
  Widget _buildProductGrid(List<dynamic> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.6, // Tăng nhẹ để phần tên và giá rộng rãi hơn
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildModernProductCard(products[index]),
    );
  }

  Widget _buildModernProductCard(dynamic p) {
    final price = double.tryParse(p['price'].toString()) ?? 0.0;
    final f = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p['image_url'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 34,
                  child: Text(
                    p['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        f.format(price),
                        style: const TextStyle(color: kleverMain, fontWeight: FontWeight.bold, fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await CartService.addToCart(p);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đã thêm vào giỏ!"), duration: Duration(milliseconds: 500)),
                        );
                      },
                      child: const Icon(Icons.add_circle, color: kleverDark, size: 22),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPremiumHero() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=2070'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SẢN PHẨM SẠCH\nGIA ĐÌNH", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                  onPressed: () {},
                  child: const Text("XEM CHI TIẾT", style: TextStyle(fontSize: 10))
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    String title = widget.searchKeyword.isNotEmpty ? "Kết quả tìm cho: '${widget.searchKeyword}'" : widget.selectedCategory;
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kleverDark));
  }

  Widget _buildModernSidebar() {
    return ListView(
      padding: const EdgeInsets.only(top: 15),
      children: [
        _sidebarItem("Trái Cây Nội Địa", Icons.apple_rounded),
        _sidebarItem("Trái cây nhập khẩu", Icons.language_rounded),
        _sidebarItem("Rau sạch", Icons.eco_rounded),
        _sidebarItem("Combo Quà Tặng", Icons.card_giftcard_rounded),
      ],
    );
  }

  Widget _sidebarItem(String title, IconData icon) {
    bool isSel = widget.selectedCategory == title && widget.searchKeyword.isEmpty;
    return ListTile( 
      leading: Icon(icon, color: isSel ? kleverMain : Colors.grey, size: 18),
      title: Text(title, style: TextStyle(color: isSel ? kleverMain : Colors.black87, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      onTap: () => widget.onCategoryChanged(title),
      selected: isSel,
      selectedTileColor: kleverSoft,
    );
  }

  Widget _buildNoProductWidget() => const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("Không tìm thấy sản phẩm nào.", style: TextStyle(color: Colors.grey))));
  Widget _buildErrorWidget(String error) => Center(child: Text("Lỗi kết nối: Vui lòng kiểm tra XAMPP hoặc Server của bạn."));
}