class ProductDetailModel {
  final String? id;
  final String? name;
  final String? info;
  final double? price;
  final double? shipping;
  final double? total;

  ProductDetailModel({
    this.id,
    this.name,
    this.info,
    this.price,
    this.shipping,
    this.total,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json["id"],
      name: json["name"],
      info: json["info"],
      price:
          json["price"] != null
              ? double.tryParse(json["price"].toString())
              : null,
      shipping:
          json["shipping"] != null
              ? double.tryParse(json["shipping"].toString())
              : null,
      total:
          json["total"] != null
              ? double.tryParse(json["total"].toString())
              : null,
    );
  }
}
