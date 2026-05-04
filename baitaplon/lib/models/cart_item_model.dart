class CartItemModel {
  final int productId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  // Chuyển đổi từ dữ liệu JSON của PHP sang Object Flutter
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: int.tryParse((json['product_id'] ?? json['id']).toString()) ?? 0,
      name: json['name'] ?? 'Sản phẩm',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
    );
  }

  double get subTotal => price * quantity;
}