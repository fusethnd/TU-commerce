
import 'dart:ffi';


class Product{
  late double price;
  late String prodID;
  late String prodName;
  late String details;
  String category;
  late String imageUrl;
  late bool instock;
  late Map<String, dynamic>? seller;

  Product({required this.category});
}