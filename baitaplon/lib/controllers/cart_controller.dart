import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartController {
  Future<List<CartItemModel>> fetchCartItems() async {
    final items = await CartService.getCart();
    return items.map((item) => CartItemModel.fromJson(item)).toList();
  }

  Future<bool> updateQuantity(int productId, int newQty) async {
    return await CartService.updateQuantity(productId, newQty);
  }

  Future<bool> removeItem(int productId) async {
    return await CartService.removeFromCart(productId);
  }

  Future<void> clearAll() async {
    await CartService.clearCart();
  }

  double calculateTotal(List<CartItemModel> items) {
    return items.fold(0, (sum, item) => sum + item.subTotal);
  }
}