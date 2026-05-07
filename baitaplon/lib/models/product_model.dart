class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description; // THÊM DÒNG NÀY

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description, // THÊM DÒNG NÀY
  });

  // Chuyển đổi từ JSON sang Object Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      // Đảm bảo key 'description' khớp với tên cột trong database của bạn
      description: json['description']?.toString() ?? 'Sản phẩm chưa có mô tả.',
    );
  }
}
