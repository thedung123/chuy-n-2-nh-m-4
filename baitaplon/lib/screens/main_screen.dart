import 'package:flutter/material.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/header_widget.dart';
import 'home_content.dart';
import 'auth_screen.dart';
import 'cart_screen.dart';
import 'OrderHistoryScreen.dart';
import 'user_session.dart'; // ĐẢM BẢO ĐÃ IMPORT FILE RIÊNG

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const Color kleverGreen = Color(0xFF2E7D32);

  String selectedCategory = "Trái Cây Nội Địa";
  String searchKeyword = "";
  int _currentTabIndex = 0;
  List<String> _notifications = [];

  // Giao diện Trang Cá Nhân
  Widget _buildProfilePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: kleverGreen.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 45, color: kleverGreen),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lấy tên thật từ database (ví dụ: Nguyễn Dũng)
                    Text(
                      UserSession.fullName ?? "Người dùng",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      UserSession.username ?? "chưa đăng nhập",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _profileMenuItem(Icons.history, "Lịch sử mua hàng", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
          }),
          _profileMenuItem(Icons.location_on_outlined, "Sổ địa chỉ", () {}),
          _profileMenuItem(Icons.favorite_border, "Sản phẩm yêu thích", () {}),
          _profileMenuItem(Icons.settings_outlined, "Cài đặt tài khoản", () {}),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    UserSession.clearSession(); // Xóa sạch dữ liệu trong kho
                  });
                },
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red)
                ),
                child: const Text("ĐĂNG XUẤT"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: kleverGreen),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        return HomeContent(
          selectedCategory: selectedCategory,
          searchKeyword: searchKeyword,
          onCategoryChanged: (val) => setState(() {
            selectedCategory = val;
            searchKeyword = "";
          }),
        );
      case 1:
        return const Center(child: Text("Hãy nhập từ khóa vào ô tìm kiếm phía trên"));
      case 2:
      // Sử dụng UserSession.isLoggedIn để kiểm tra quyền truy cập
        return UserSession.isLoggedIn ? _buildProfilePage() : _buildLoginRequired();
      case 3:
        return _buildNotificationPage();
      default:
        return const Center(child: Text("Đang cập nhật..."));
    }
  }

  Widget _buildNotificationPage() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Không có thông báo mới", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text("Thông báo"),
          subtitle: Text(_notifications[index]),
          trailing: const Text("Vừa xong", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Vui lòng đăng nhập để xem hồ sơ"),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _goToAuthPage,
            style: ElevatedButton.styleFrom(backgroundColor: kleverGreen),
            child: const Text("ĐĂNG NHẬP NGAY", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _goToAuthPage() {
    bool isLoginLocal = true;
    Navigator.push(context, MaterialPageRoute(builder: (context) => StatefulBuilder(builder: (context, setModalState) {
      return AuthScreen(
        isLogin: isLoginLocal,
        onSuccess: () {
          Navigator.pop(context);
          setState(() {
            // Sau khi đăng nhập thành công, UserSession đã có dữ liệu từ AuthScreen
            _currentTabIndex = 2;
            _notifications.add("Chào mừng ${UserSession.fullName} quay trở lại!");
          });
        },
        onSwitch: (bool newValue) => setModalState(() => isLoginLocal = newValue),
      );
    })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TopBarWidget(onHome: () => setState(() {
                  _currentTabIndex = 0;
                  searchKeyword = "";
                })),
                HeaderWidget(
                  onLogoTap: () => setState(() {
                    _currentTabIndex = 0;
                    searchKeyword = "";
                  }),
                  // Nhấn vào icon tài khoản cũng kiểm tra trạng thái session
                  onAccountTap: UserSession.isLoggedIn
                      ? () => setState(() => _currentTabIndex = 2)
                      : _goToAuthPage,
                  onCartTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                  onSearch: (value) {
                    setState(() {
                      searchKeyword = value;
                      _currentTabIndex = 0;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
        backgroundColor: kleverGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.shopping_basket_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(index: 0, icon: Icons.home_filled, label: "Trang chủ"),
              _buildTabItem(index: 1, icon: Icons.search_rounded, label: "Tìm kiếm"),
              const SizedBox(width: 40),
              _buildTabItem(index: 3, icon: Icons.notifications_none_rounded, label: "Thông báo"),
              _buildTabItem(index: 2, icon: Icons.person_outline_rounded, label: "Cá nhân"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required int index, required IconData icon, required String label}) {
    bool isSelected = _currentTabIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? kleverGreen : Colors.grey, size: 24),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? kleverGreen : Colors.grey)),
        ],
      ),
    );
  }
}
