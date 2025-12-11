import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jin_reflex_new/model/shop/ui_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int activeImage = 0;

  Product? detailProduct; // API filled data

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    fetchDetail(); // load full detail
    super.initState();
  }

  Future<void> fetchDetail() async {
    // get detail from API
    final fetched = await fetchProductDetail(
      pid: "22",
      productId: widget.product.id,
    );

    setState(() {
      detailProduct = fetched;
    });
  }

  Product get p => detailProduct ?? widget.product;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---- API CALL (HTML safe) ---- //

  Future<Product> fetchProductDetail({
    required String pid,
    required String productId,
  }) async {
    final url =
        "https://jinreflexology.in/api/getproductdetail.php?pid=$pid&product_id=$productId";

    try {
      final resp = await http.get(Uri.parse(url));
      final raw = resp.body;

      final start = raw.indexOf("{");
      final end = raw.lastIndexOf("}") + 1;

      if (start == -1 || end == -1) {
        throw Exception("JSON not found");
      }

      final jsonStr = raw.substring(start, end);
      final Map<String, dynamic> data = json.decode(jsonStr);

      final Map<String, dynamic> detailJson = data["data"] ?? {};

      return convertDetailToUI(detailJson);
    } catch (e) {
      print("Detail API Error: $e");
      return widget.product; // fallback
    }
  }

  // ---- JSON → UI Product ---- //

  Product convertDetailToUI(Map<String, dynamic> json) {
    return Product(
      id: json["id"] ?? "",
      title: json["name"] ?? "",
      image: "assets/hand_left.png",
      price: double.tryParse(json["total"]?.toString() ?? "0") ?? 0,
      details: json["info"] ?? "",
      description: json["info"] ?? "",
      additionalInfo: "Shipping ₹ ${json["shipping"] ?? "0"}",
    );
  }

  // ---- UI Helpers ---- //

  String imageAt(dynamic imgSource, int index) {
    if (imgSource is List<String>) {
      if (imgSource.isEmpty) return '';
      final idx = index.clamp(0, imgSource.length - 1);
      return imgSource[idx];
    } else if (imgSource is String) {
      return imgSource;
    }
    return '';
  }

  int imageCount(dynamic imgSource) {
    if (imgSource is List<String>) return imgSource.length;
    if (imgSource is String) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final int imgCount = imageCount(p.image);

    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 30,
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF7C85A)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            imgCount > 0
                                ? Image.asset(
                                  imageAt(p.image, activeImage),
                                  fit: BoxFit.contain,
                                )
                                : const Center(child: Icon(Icons.image)),
                      ),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imgCount,
                          itemBuilder: (context, i) {
                            return GestureDetector(
                              onTap: () {
                                setState(() => activeImage = i);
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: activeImage == i ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child:
                                        imgCount > 0
                                            ? Image.asset(
                                              imageAt(p.image, i),
                                              fit: BoxFit.contain,
                                            )
                                            : const SizedBox.shrink(),
                                  ),
                                  Container(
                                    width: 70,
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: activeImage == i ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child:
                                        imgCount > 0
                                            ? Image.asset(
                                              imageAt(p.image, i),
                                              fit: BoxFit.contain,
                                            )
                                            : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Title + Price + Add to Cart
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "₹ ${p.price}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Add To Cart",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        "4G Super Power useful",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            productTabs(
              controller: _tabController,
              details: p.details,
              description: p.description,
              additionalInfo: p.additionalInfo,
            ),

            sectionTitle("How to use 4G Super Power - Practical Session"),
            Container(
              height: 200,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.image, size: 40)),
            ),

            sectionTitle("Browse Other Products -"),
            const SizedBox(height: 120), // placeholder
          ],
        ),
      ),
    );
  }

  Widget infoBox(String text) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text),
    );
  }

  Widget sectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFFF0E6D6),
        border: Border(
          left: BorderSide(color: Color(0xFFF7C85A), width: 3),
          right: BorderSide(color: Color(0xFFF7C85A), width: 3),
        ),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(12),
          right: Radius.circular(12),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget productTabs({
    required TabController controller,
    required String details,
    required String description,
    required String additionalInfo,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.amber.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: controller,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: "Details"),
              Tab(text: "Description"),
              Tab(text: "Additional Info"),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: TabBarView(
            controller: controller,
            children: [
              infoBox(details),
              infoBox(description),
              infoBox(additionalInfo),
            ],
          ),
        ),
      ],
    );
  }
}
