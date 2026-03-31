import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

/// ROOT APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

/// LOGIN PAGE
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  bool isLogin = true;

  final username = TextEditingController();
  final password = TextEditingController();
  final email = TextEditingController();

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    username.dispose();
    password.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                      Colors.red.shade200,
                      Colors.green.shade600,
                      controller.value)!,
                  Color.lerp(
                      Colors.orange.shade300,
                      Colors.green.shade900,
                      controller.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

            child: Stack(
              children: [

                floatingApple(),

                Center(
                  child: SingleChildScrollView(
                    child: buildCard(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// APPLE FLOAT
  Widget floatingApple() {

    return AnimatedPositioned(
      duration: const Duration(seconds: 6),

      top: controller.value * 250,
      left: 40,

      child: const Text(
        "🍎",
        style: TextStyle(fontSize: 120),
      ),
    );
  }

  /// CARD LOGIN UI
  Widget buildCard() {

    return Container(
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(30),

        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black26,
          )
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          AnimatedScale(
            scale: 1 + controller.value * .1,
            duration: const Duration(milliseconds: 400),

            child: const Text(
              "🍎",
              style: TextStyle(fontSize: 80),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Klever Fruits",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 20),

          if (!isLogin)
            buildInput(email, "Email", Icons.email),

          if (!isLogin)
            const SizedBox(height: 15),

          buildInput(
              username,
              "Tên đăng nhập",
              Icons.person),

          const SizedBox(height: 15),

          buildInput(
              password,
              "Mật khẩu",
              Icons.lock,
              isPassword: true),

          const SizedBox(height: 25),

          buildButton(),

          TextButton(
            onPressed: () {

              setState(() {
                isLogin = !isLogin;
              });

            },
            child: Text(
              isLogin
                  ? "Chưa có tài khoản? Đăng ký"
                  : "Đã có tài khoản? Đăng nhập",
            ),
          )
        ],
      ),
    );
  }

  /// INPUT FIELD
  Widget buildInput(
      TextEditingController controller,
      String label,
      IconData icon,
      {bool isPassword = false}) {

    return TextField(
      controller: controller,
      obscureText: isPassword,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  /// LOGIN BUTTON
  Widget buildButton() {

    return GestureDetector(
      onTap: () {

        if (isLogin) {

          if (username.text == "admin"
              && password.text == "123") {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );

          } else {

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                    "Sai tài khoản hoặc mật khẩu"),
              ),
            );
          }

        } else {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text("Đăng ký thành công"),
            ),
          );
        }
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),

        height: 50,
        width: double.infinity,

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.green,
              Colors.orange
            ],
          ),

          borderRadius: BorderRadius.circular(15),
        ),

        alignment: Alignment.center,

        child: Text(
          isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18),
        ),
      ),
    );
  }
}