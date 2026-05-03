import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart'; // Đảm bảo file này đã tồn tại

class AuthScreen extends StatefulWidget {
  final bool isLogin;
  final VoidCallback onSuccess;
  final Function(bool) onSwitch;

  const AuthScreen({
    super.key,
    required this.isLogin,
    required this.onSuccess,
    required this.onSwitch,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAuth() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError("Vui lòng điền đầy đủ thông tin");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String fileName = widget.isLogin ? 'login.php' : 'register.php';
      final url = Uri.parse("http://localhost:8080/klever_fruits_api/$fileName");

      final response = await http.post(
        url,
        body: {"username": username, "password": password},
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // --- SỬA TẠI ĐÂY ---
        // Không check widget.isLogin nữa. Cứ thành công là lưu Session để có ID mới
        if (data['user'] != null) {
          UserSession.setSession(data['user']);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message']))
          );
          widget.onSuccess();
        }
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      _showError("Lỗi kết nối Server");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thông báo"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(widget.isLogin ? "Đăng nhập" : "Đăng ký"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.eco_rounded, color: primaryGreen, size: 80),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        Text(
                          widget.isLogin ? "Chào mừng trở lại!" : "Tạo tài khoản",
                          style: const TextStyle(color: primaryGreen, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        _buildInputField(
                          label: "Email / Tài khoản",
                          hint: "example@gmail.com",
                          controller: _usernameController,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: "Mật khẩu",
                          hint: "********",
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading) ...[
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Text(
                                  _isLoading
                                      ? (widget.isLogin ? "ĐANG XỬ LÝ..." : "ĐANG TẠO...")
                                      : (widget.isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ"),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.isLogin ? "Chưa có tài khoản?" : "Đã có tài khoản?"),
                            TextButton(
                              onPressed: () {
                                _usernameController.clear();
                                _passwordController.clear();
                                widget.onSwitch(!widget.isLogin);
                              },
                              child: Text(widget.isLogin ? "Đăng ký" : "Đăng nhập"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF1F8E9),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none
            ),
          ),
        ),
      ],
    );
  }
}