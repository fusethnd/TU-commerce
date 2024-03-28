import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tu_commerce/model/product.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:uuid/uuid.dart'; 
import 'package:file_picker/file_picker.dart';

class AddProduct extends StatefulWidget {
  final Map<String, dynamic>?  username;
  
  AddProduct({Key? key, required this.username}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

// ตอนนี้ยังไม่เสร็จนะแต่ push ไว้ก่อน
class _AddProductState extends State<AddProduct> {

  Product product = Product(category: 'normal'); // class prodcut  จากใน model
  final _formKey = GlobalKey<FormState>(); // เอาไว update status ของ TextFormField
  File? _image; // hold image path
  String uuid = Uuid().v4(); // Generate a random UUID 
  
  void _generateNewUuid() { 
    setState(() { 
      uuid = Uuid().v4(); // Generate a new random UUID 
    }); 
  } 

  Future pickImageFromGallery() async { //ฟังชั่นเรียกใช้ file ในเครื่อง
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery); // เรียกจาก gallery
    if(returnedImage == null) return;
    setState(() {
      _image = File(returnedImage.path); // save path ที่เจอลง _image เป็น global variable
    });
  }
  // upload to FireStore 
  Future uploadImageToFirebase(BuildContext context) async{
    if (_image == null) {
      return;
    }
    String filename = "${product.prodName}.png";
    Reference ref = FirebaseStorage.instance.ref().child('product/$filename');
    UploadTask uploadTask = ref.putFile(_image!);
    await uploadTask.whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload')));
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product"),),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ----------- ปุ่มกดเลือกภาพ -----------
            ElevatedButton(
              onPressed: pickImageFromGallery, // เรียฟังชั่นเลือกภาพ
              child: const Text('Select Image')
            ),

            // ----------- ช่องใส่ product name ---------
            const Text("product name"),
            TextFormField(
              onSaved: (name) {
                product.prodName = name!;
                product.seller = widget.username!; // แอบ save Username ไปด้วย
              },
            ),
            // ---------- จบช้อง product name -------------

            // ---------- ช่องใส่ describtion -------------
            const Text("product describtion"),
            TextFormField(
              onSaved: (describ) {
                product.details = describ!;
              },
            ),
            // ---------- จบช่อง product describtion -------------

            // ----------- ใส่ catagory -----------
            const Text("Category"),
            DropdownButton<String>(
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
            // ---------- จบ category ----------
            // ---------- ช่องใส่ ราคา ------------
            const Text("Price"),
            TextFormField(
              onSaved: (price) {
                product.price = double.parse(price!);
              },
            ),
            // ---------- จบ ช่องใส่ ราคา ------------
            // ---------- ปุ่ม เซฟ      -------------
            ElevatedButton(
              onPressed: () {
                _formKey.currentState!.save(); // update status ของ Text From Field ที่ใส่มาทั้งหมด
                // print(product.prodName);
                uploadImageToFirebase(context);
                Navigator.pop(context);
              }, 
              child: const Text('Save'),
            )
            // ---------------------------
          ],
        ),
      ),
    );
  }
}