


class Product{
  late double price;
  late String prodID;
  late String prodName;
  late String details;
  String category;
  late String imageUrl;
  String? linkUrl;
  late bool instock;
  late Map<String, dynamic>? seller;
  late DateTime time;

  Product({required this.category});
}