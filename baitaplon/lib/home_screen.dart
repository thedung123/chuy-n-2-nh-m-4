import 'package:flutter/material.dart';
import 'fruit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Klever Fruits 🍎"),
        backgroundColor: Colors.green,
        centerTitle: true,

        actions: [

          IconButton(
            icon: const Icon(Icons.shopping_cart),

            onPressed: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Mở giỏ hàng"),
                ),
              );

            },
          )

        ],
      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            searchBox(),

            bannerWidget(),

            introWidget(),

            categoryTitle(),

            categoryList(context),

          ],
        ),
      ),
    );
  }


  /// SEARCH BOX
  Widget searchBox() {

    return Padding(

      padding: const EdgeInsets.all(12),

      child: TextField(

        decoration: InputDecoration(

          hintText: "Tìm kiếm rau củ quả...",

          prefixIcon: const Icon(Icons.search),

          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(20),

            borderSide: BorderSide.none,

          ),
        ),
      ),
    );
  }


  /// BANNER
  Widget bannerWidget() {

    return Container(

      height: 160,

      margin: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(20),

        gradient: const LinearGradient(

          colors: [
            Colors.green,
            Colors.orange
          ],
        ),
      ),

      child: const Center(

        child: Text(

          "Fresh Vegetables & Fruits Everyday 🥬🍎",

          style: TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

            color: Colors.white,

          ),
        ),
      ),
    );
  }


  /// INTRO
  Widget introWidget() {

    return Padding(

      padding: const EdgeInsets.all(15),

      child: Card(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        child: const Padding(

          padding: EdgeInsets.all(15),

          child: Text(

            "Klever Fruits là ứng dụng cung cấp rau củ quả tươi sạch mỗi ngày. "
                "Chúng tôi cam kết mang đến sản phẩm chất lượng cao với giá cả hợp lý "
                "và giao hàng nhanh chóng đến tận tay khách hàng.",

            style: TextStyle(fontSize: 16),

            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }


  /// TITLE
  Widget categoryTitle() {

    return const Padding(

      padding: EdgeInsets.only(left: 15, top: 10),

      child: Align(

        alignment: Alignment.centerLeft,

        child: Text(

          "Danh mục sản phẩm",

          style: TextStyle(

            fontSize: 20,

            fontWeight: FontWeight.bold,

          ),
        ),
      ),
    );
  }


  /// CATEGORY LIST
  Widget categoryList(BuildContext context) {

    return Column(

      children: [

        categoryCard(
          context,
          "🍎 Trái cây",
          "Từ 50.000đ/kg",
          const FruitScreen(),
        ),

        categoryCard(
          context,
          "🥬 Rau xanh",
          "Từ 15.000đ/kg",
          null,
        ),

        categoryCard(
          context,
          "🥕 Củ quả",
          "Từ 20.000đ/kg",
          null,
        ),

        categoryCard(
          context,
          "🍊 Trái cây nhập khẩu",
          "Từ 120.000đ/kg",
          null,
        ),

      ],
    );
  }


  /// CATEGORY CARD
  Widget categoryCard(
      BuildContext context,
      String name,
      String price,
      Widget? screen,
      ) {

    return Container(

      margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8),

      child: Card(

        elevation: 4,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        child: ListTile(

          leading: Text(
            name.split(" ")[0],
            style: const TextStyle(fontSize: 30),
          ),

          title: Text(
            name,
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),

          subtitle: Text("Giá tham khảo: $price"),

          trailing: const Icon(Icons.arrow_forward_ios),

          onTap: () {

            if (screen != null) {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => screen,
                ),
              );

            } else {

              ScaffoldMessenger.of(context)
                  .showSnackBar(

                SnackBar(
                  content:
                  Text("Danh mục $name đang cập nhật"),
                ),
              );

            }
          },
        ),
      ),
    );
  }
}