import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giới thiệu bản thân',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🖼️ Avatar (ảnh từ Postimg)
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: Image.network(
                    'https://i.postimg.cc/MZ1tp8gt/sang.jpg',
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,

                    // ⏳ loading
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      );
                    },

                    // ❌ lỗi ảnh
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 👤 Tên
              const Text(
                'Lê Văn Sáng',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 💼 Nghề nghiệp
              const Text(
                'Sinh viên IT / Flutter Developer',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 12),

              // 📞 Thông tin
              const Text('📧 Email: sangle@gmail.com'),
              const Text('📱 SĐT: 0332382616'),

              const SizedBox(height: 20),

              // 📝 Giới thiệu
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Tôi đam mê lập trình và đang học phát triển ứng dụng mobile bằng Flutter. '
                  'Mục tiêu của tôi là trở thành lập trình viên chuyên nghiệp.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
