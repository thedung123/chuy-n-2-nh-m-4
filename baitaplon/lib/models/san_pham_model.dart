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
