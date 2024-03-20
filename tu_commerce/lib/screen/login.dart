import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/customerHome.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();


}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase, 
      builder: (context,snapshot) {
      if(snapshot.connectionState == ConnectionState.done){
              return Scaffold(
            appBar: AppBar(title: const Text("Login"),),
            body: Container(
              child: Form(
                child: Column(
                  children: 
                  [
                    const Text("E mail"),
                    TextFormField(),
                    const Text("Password"),
                    TextFormField(),
                    SizedBox
                    (
                      child: ElevatedButton.icon(onPressed: ()
                      {
                        Navigator.push
                        (
                          context,MaterialPageRoute
                          (builder: (context)
                            {
                              return const CustomerHome();
                            }
                          )
                        );
                      }, 
                      icon: const Icon(Icons.login), 
                      label: const Text("Login")),
                    )
                  ],
                )
                ),
              ),
              

          );
        }else{
          return Scaffold(
                appBar: AppBar(
                  title: Text("Error"),
                  ),
                body: Center(child: Text("${snapshot.error}"),
                ),
            );
        }
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