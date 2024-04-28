import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tu_commerce/function/Firebase.dart';
import 'package:tu_commerce/model/product.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:uuid/uuid.dart'; 
import 'package:file_picker/file_picker.dart';

class AddProduct extends StatefulWidget {
  final Map<String, dynamic>  username;
  
  AddProduct({Key? key, required this.username}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

// ตอนนี้ยังไม่เสร็จนะแต่ push ไว้ก่อน
class _AddProductState extends State<AddProduct> {

  Product product = Product(category: 'normal'); // class prodcut  จากใน model
  final _formKey = GlobalKey<FormState>(); // เอาไว update status ของ TextFormField
  File? _image; // hold image path
  String uuid = const Uuid().v4(); // Generate a random UUID 
  late BuildContext scaffoldContext;
  UploadTask? uploadTask;
  String url = '';
  bool _isButtonClicked = false;

  Future pickImageFromGallery() async { //ฟังชั่นเรียกใช้ file ในเครื่อง
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery); // เรียกจาก gallery
    if(returnedImage == null) return;
    setState(() {
      _image = File(returnedImage.path); // save path ที่เจอลง _image เป็น global variable
    });
    print(_image);
  }
  
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldContext = context; // Save scaffold's context
  }
  // upload to FireStore 
  Future<void> uploadImageToFirebase(BuildContext context) async{
    if (_image == null) {
      return;
    }
    String filename = "${product.prodName}.png";
    Reference ref = FirebaseStorage.instance.ref().child('product/$filename');
    uploadTask = ref.putFile(_image!);
    final snapshot = await uploadTask;
    print('----complete---');
    print(snapshot);
    String? urlCheck = await snapshot?.ref.getDownloadURL();
    // print('pass');
    // print(product.linkUrl);
    // print('Dowload link: $url');
    if (mounted){
      print('pass mounted------------');
      setState(() {
          // url = urlCheck!;
        product.linkUrl = urlCheck!;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: MaterialApp(
        theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(50),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(50),
            ),
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color.fromRGBO(219, 241, 240, 1.0),
            contentPadding: const EdgeInsets.only(left: 25),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(54, 91, 109, 1.0)),
              foregroundColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 1)),
              textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16,),),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal:40, vertical: 15),),
            ),
          )
        ),
        home: Form(
          key: _formKey,
          child: Stack(
            children: [
              Container(),
              Stack(
                children: [
                  Container(
                    color: Colors.white,
                    height: screenHeight * 0.6,
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/DefaultImg.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                        shadowColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: pickImageFromGallery,
                      child: const Icon(
                        Icons.add_circle_rounded,
                        size: 70,
                        color: Color.fromRGBO(54, 91, 109, 1.0),
                      )
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromRGBO(242, 241, 236, 1),
                    ),
                    height: screenHeight * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextFormField(
                          validator: RequiredValidator(errorText: "Need product name").call,
                          onSaved: (name) {
                            product.prodName = name!;
                            product.imageUrl = "product/${product.prodName}.png";
                            product.seller = widget.username; // แอบ save Username ไปด้วย
                            product.prodID = uuid;
                            product.instock = true;
                            product.time = DateTime.now();
                          },
                          decoration: const InputDecoration(labelText: 'Product Name'),
                        ),
                        TextFormField(
                          validator: RequiredValidator(errorText: "Need describtion").call,
                          onSaved: (describ) {
                            product.details = describ!;
                          },
                          decoration: const InputDecoration(labelText: 'Description'),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(219, 241, 240, 1.0),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: DropdownButton<String>(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            isExpanded: true,
                            value: product.category, 
                            items: const [
                              DropdownMenuItem<String>(value: "normal",child: Text('ของใช้ทั่วไป'),),
                              DropdownMenuItem<String>(value: 'electric',child: Text('ของใช้ไฟฟ้า'),),
                            ],
                            onChanged: (value){
                              setState(() {
                                product.category = value!;
                              });
                            },
                          ),
                        ),
                        TextFormField(
                          validator: RequiredValidator(errorText: "Need Price").call,
                          onSaved: (price) {
                            product.price = double.parse(price!);
                          },
                          decoration: const InputDecoration(labelText: 'Price'),
                        ),
                        ElevatedButton(
                          onPressed: _isButtonClicked ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              
                              _formKey.currentState!.save(); // update status ของ Text From Field ที่ใส่มาทั้งหมด
                              if (widget.username.containsKey('Credit') == false){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('')),
                                  );
                              }else {
                                  setState(() {
                                    _isButtonClicked = true;
                                  });
                                  await uploadImageToFirebase(context);
                                  // _formKey.currentState!.save();
                                  // product.linkUrl = url;
                                  print('------------ url -------------');
                                  print(product.imageUrl);
                                  print('-------------link url --------');
                                  print(product.linkUrl);
                                  await saveProductDB(product);
                                  // _formKey.currentState!.reset();
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                                      return Navigation(username: widget.username, temp: 0);
                                  }
                                ),(Route<dynamic> route) => false);
                              }
                            }
                          }, 
                          child: const Text('Save'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // Positioned(
              //   top: 40,
              //   left: 20,
              //   child: RawMaterialButton(
              //     padding: const EdgeInsets.all(10),
              //     constraints: const BoxConstraints(minWidth: 36),
              //     shape: const CircleBorder(),
              //     fillColor: const Color.fromRGBO(54, 91, 109, 1.0),
              //     onPressed: () => Navigator.of(context).pop(),
              //     child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,),
              //   )
              // )
            ],
          ),
        ),
      ),
    );
  }
}