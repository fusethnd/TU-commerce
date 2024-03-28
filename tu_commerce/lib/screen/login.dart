import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:tu_commerce/firebase_options.dart';
import 'package:tu_commerce/screen/customerHome.dart';
import 'package:tu_commerce/screen/navigationbarSeller.dart';
import 'package:tu_commerce/screen/sellerHome.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();


}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final Future<FirebaseApp> firebase = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // start firebase
  final _emailController = TextEditingController(); // ตัวรับ Text emil จาก web login อยุ่ใน TextFromField
  final _passwordController = TextEditingController(); // ตัวรับ Text password จาก web login อยุ่ใน TextFromField

  
  @override
  void dispose() { // restart ตัวแปร
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase, 
      builder: (context,snapshot) {
      if (snapshot.hasError){
        return Scaffold(
              appBar: AppBar(
                title: const Text("Error"),
                ),
              body: Center(child: Text("${snapshot.error}"),
              ),
          );
      }
      
      if(snapshot.connectionState == ConnectionState.done){ // ดู connection
            return Scaffold(
            appBar: AppBar(title: const Text("Login"),),
            body: Form(
              key: _formKey, 
              child: Column(
                children: 
                [
                  const Text("E mail"), // Block ข้อความ Email
                  TextFormField(
                    controller: _emailController, // กำหนัดตัวแปร email เอาไว้ใช้เช็คตอน FirebaseAuth
                    validator: MultiValidator([
                              RequiredValidator(errorText: "Require Email"),
                              EmailValidator(errorText: "Email wrong format")
                            ]).call, // บังคับให้เมล + เช็ค format mail
                    keyboardType: TextInputType.emailAddress, // เพิ่มตัว @ ใน Email
                  ),
                  const Text("Password"),
                  TextFormField(
                    controller: _passwordController, // กำหนัดตัวแปร password เอาไว้ใช้เช็คตอน FirebaseAuth
                    validator: RequiredValidator(errorText: "Enter You Password").call, // บังคับให้
                    obscureText: true
                  ),
            
                  SizedBox
                  (
                    child: ElevatedButton.icon( // ปุ่มกด 
                      onPressed: () async
                    {
                      if (_formKey.currentState!.validate()){ // check state ว่าถูกต้องมั้ย เช็ค Email กับ password
                    
                        _formKey.currentState!.save(); // save sate 
                        try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword( // check Email กับ password ว่าตรงกับใน Firebase มั้ย
                          email: _emailController.text.trim(), 
                          password: _passwordController.text.trim()
                          ).then((value){
                            _formKey.currentState!.reset(); // reset state
                            Navigator.pushReplacement(  // ลิ้งไปหน้า Customer Home
                              context,MaterialPageRoute(builder: (context){
                                return Navigation();
                              })
                            );
                          });
                        } catch (e) {
                          String errorMessage = "User not found"; // check Error
                            if (e is FirebaseAuthException) {
                              switch (e.code) {
                                case 'user-not-found':
                                  errorMessage = 'User not found';
                                  break;
                                case 'wrong-password':
                                  errorMessage = 'Wrong password';
                                  break;
                                case 'invalid-email':
                                  errorMessage = 'Invalid email';
                                  break;
                                // Add more cases as needed
                              }
                            }
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(// sent Error
                              SnackBar(
                                content: Text(errorMessage), 
                              ),
                            );
                          }
                      }
                    }, 
                    icon: const Icon(Icons.login), // icon login
                    label: const Text("Login")),
                  )
                ],
              )
              ),
          );
        }
        return const Scaffold( // ถ้าเกิดไม่มีเน็ทจะโชว์หน้าหมุนๆ 
            body: Center(
              child: CircularProgressIndicator(),
            ),);
      }
      
      );
    // Scaffold(
    //   appBar: AppBar(title: const Text("Login"),),
    //   body: Container(
    //     child: Form(
    //       child: Column(
    //         children: 
    //         [
    //           const Text("E mail"),
    //           TextFormField(),
    //           const Text("Password"),
    //           TextFormField(),
    //           SizedBox
    //           (
    //             child: ElevatedButton.icon(onPressed: ()
    //             {
    //               Navigator.push
    //               (
    //                 context,MaterialPageRoute
    //                 (builder: (context)
    //                   {
    //                     return const CustomerHome();
    //                   }
    //                 )
    //               );
    //             }, 
    //             icon: const Icon(Icons.login), 
    //             label: const Text("Login")),
    //           )
    //         ],
    //       )
    //       ),
    //     ),
        

    // );
  }
}