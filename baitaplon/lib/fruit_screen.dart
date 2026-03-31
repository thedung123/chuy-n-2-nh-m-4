import 'package:flutter/material.dart';

class FruitScreen extends StatelessWidget {
  const FruitScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final fruits = [

      {
        "name": "Táo Mỹ",
        "price": "65.000đ/kg",
        "desc": "Táo giòn ngọt, giàu vitamin C",
        "image":
        "https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg"
      },

      {
        "name": "Nho Hàn Quốc",
        "price": "120.000đ/kg",
        "desc": "Nho không hạt, mọng nước",
        "image":
        "https://i.postimg.cc/633VNH81/unnamed-5-9141a5da32ff4701be8cc50fd795463c-1024x1024.png"
      },

      {
        "name": "Cam Úc",
        "price": "90.000đ/kg",
        "desc": "Cam ngọt nhiều nước",
        "image":
        "https://upload.wikimedia.org/wikipedia/commons/c/c4/Orange-Fruit-Pieces.jpg"
      },

      {
        "name": "Dâu Hàn Quốc",
        "price": "180.000đ/kg",
        "desc": "Dâu đỏ mọng tươi ngon",
        "image":
        "https://upload.wikimedia.org/wikipedia/commons/2/29/PerfectStrawberry.jpg"
      },

      {
        "name": "Kiwi New Zealand",
        "price": "140.000đ/kg",
        "desc": "Giàu chất xơ tốt tiêu hóa",
        "image":
        "https://upload.wikimedia.org/wikipedia/commons/d/d3/Kiwi_aka.jpg"
      },

      {
        "name": "Cherry Mỹ",
        "price": "250.000đ/kg",
        "desc": "Cherry nhập khẩu cao cấp",
        "image":
        "https://upload.wikimedia.org/wikipedia/commons/b/bb/Cherry_Stella444.jpg"
      },

    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Danh sách Trái cây 🍎"),
        backgroundColor: Colors.green,
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(10),

        itemCount: fruits.length,

        itemBuilder: (context, index) {

          final fruit = fruits[index];

          return fruitCard(
            context,
            fruit["name"]!,
            fruit["price"]!,
            fruit["desc"]!,
            fruit["image"]!,
          );
        },
      ),
    );
  }


  Widget fruitCard(
      BuildContext context,
      String name,
      String price,
      String desc,
      String image,
      ) {

    return Card(

      elevation: 5,

      margin: const EdgeInsets.symmetric(vertical: 10),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(

        padding: const EdgeInsets.all(10),

        child: Row(

          children: [

            ClipRRect(

              borderRadius: BorderRadius.circular(15),

              child: Image.network(
                image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(desc),

                  const SizedBox(height: 5),

                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton.icon(

              onPressed: () {

                ScaffoldMessenger.of(context)
                    .showSnackBar(

                  SnackBar(
                    content:
                    Text("$name đã thêm vào giỏ hàng"),
                  ),
                );
              },

              icon: const Icon(Icons.shopping_cart),

              label: const Text("Thêm"),
            )
          ],
        ),
      ),
    );
  }
}