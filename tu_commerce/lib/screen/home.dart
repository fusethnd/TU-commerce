import 'package:flutter/material.dart';

import 'login.dart';
import 'registerScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register/Login'),),
      body: Column(
        children: 
          [
            SizedBox(
              child: ElevatedButton.icon(onPressed: ()
              {
                Navigator.push(
                  context,MaterialPageRoute(builder: (context){
                    return const RegisterScreen();
                  })
                );
              }, 
              icon: const Icon(Icons.add), 
              label: const Text("Register")),
            ),
            SizedBox(
              child: ElevatedButton.icon(onPressed: ()
              {
                Navigator.push(
                  context,MaterialPageRoute(builder: (context){
                    return Login();
                  })
                );
              }, 
              icon: const Icon(Icons.login), 
              label: const Text("Login")),
            )
          ],
        ),
    );
  }
}