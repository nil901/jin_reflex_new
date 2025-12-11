import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jin_reflex_new/model/shop/shop_model.dart';
import 'package:jin_reflex_new/model/shop/ui_model.dart';
import 'package:jin_reflex_new/screens/products_details_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      products = await fetchProducts();
    } catch (e) {
      print("Error: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Shop")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final product = products[index];

          return GestureDetector(
            onTap: () {
              // 👉 Navigate to Detail Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFf7c85a)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(product.image, fit: BoxFit.contain),
                  ),
                  const Divider(color: Color(0xFFf7c85a)),
                  Text(
                    product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text("₹ ${product.price.toStringAsFixed(0)}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<Product>> fetchProducts() async {
    const String url = "https://jinreflexology.in/api/getproduct.php?pid=22";

    try {
      final response = await http.get(Uri.parse(url));

      final raw = response.body;
      final start = raw.indexOf("{");
      final end = raw.lastIndexOf("}") + 1;

      if (start == -1 || end == -1) {
        throw Exception("JSON not found in HTML");
      }

      final jsonStr = raw.substring(start, end);
      final Map<String, dynamic> data = json.decode(jsonStr);

      final List list = data["data"] ?? [];

      final apiList = list.map((e) => ProductModel.fromJson(e)).toList();

      return apiList.map((e) => convertToUi(e)).toList();
    } catch (e) {
      print("HTML→JSON Error: $e");
      rethrow;
    }
  }

  Product convertToUi(ProductModel m) {
    return Product(
      id: m.id,
      title: m.name,
      image: "assets/hand_left.png",
      price: m.total,
      details: m.info,
      description: m.info,
      additionalInfo: "Shipping ₹ ${m.shipping}",
    );
  }
}
