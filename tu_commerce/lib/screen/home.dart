import 'package:flutter/material.dart';

import 'login.dart';
import 'registerScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/Logo.png'),
        backgroundColor: const Color.fromRGBO(54, 91, 109, 1.0),
        toolbarHeight: 700,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        )),
      ),
      body: Column(
        children: [
          // SizedBox(
          //   child: ElevatedButton.icon(onPressed: ()
          //   {
          //     Navigator.push(
          //       context,MaterialPageRoute(builder: (context){
          //         return const RegisterScreen();
          //       })
          //     );
          //   },
          //   icon: const Icon(Icons.add),
          //   label: const Text("Register")),
          // ),
          Text(
            "Welcome to TU-Commerce",
            style: TextStyle(
              fontSize: 16, // Adjust the font size as needed
              color: Colors.white, // Set the text color
            ),
          ),
          Text(
            "Shop for everything",
            style: TextStyle(
              fontSize: 12, // Adjust the font size as needed
              color: Colors.white, // Set the text color
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Login();
                  }));
                },
                icon: const Icon(Icons.login),
                label: const Text("Get Started")),
          )
        ],
      ),
    );
  }
}
