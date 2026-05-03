import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/admin_screen.dart';
// ĐÃ SỬA: Đường dẫn đúng dựa trên cấu trúc thư mục của bạn
import 'screens/cart_service.dart';

void main() {
  // Đảm bảo Flutter framework đã sẵn sàng trước khi gọi API
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FarmersMarketApp());
}

class FarmersMarketApp extends StatefulWidget {
  const FarmersMarketApp({super.key});

  @override
  State<FarmersMarketApp> createState() => _FarmersMarketAppState();
}

class _FarmersMarketAppState extends State<FarmersMarketApp> {

  @override
  void initState() {
    super.initState();
    // Tự động lấy số lượng sản phẩm từ Database ngay khi khởi chạy App
    _initCartData();
  }

  // Hàm gọi API lấy dữ liệu giỏ hàng ban đầu
  Future<void> _initCartData() async {
    try {
      // Khi dòng import ở trên đúng, CartService ở đây sẽ hết bị gạch đỏ
      await CartService.getCart();
    } catch (e) {
      debugPrint("Lỗi khi tải dữ liệu giỏ hàng ban đầu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmers Market',
      theme: ThemeData(
        // Màu sắc chủ đạo phù hợp với logo và nông sản
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),

      // CẤU HÌNH ĐỊNH TUYẾN (ROUTES)
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),       // Màn hình chính
        '/admin': (context) => const AdminScreen(), // Màn hình Admin
      },
    );
  }
}