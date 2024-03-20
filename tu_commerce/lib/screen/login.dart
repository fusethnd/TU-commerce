import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/customerHome.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
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
  }
}