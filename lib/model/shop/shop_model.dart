class ProductModel {
  final String id;
  final String name;
  final String info;
  final double price;
  final double shipping;
  final double total;

  ProductModel({
    required this.id,
    required this.name,
    required this.info,
    required this.price,
    required this.shipping,
    required this.total,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      info: json["info"] ?? "",
      price: double.parse(json["price"].toString()),
      shipping: double.parse(json["shipping"].toString()),
      total: double.parse(json["total"].toString()),
    );
  }
}
