import 'package:flutter/material.dart';

import 'login.dart';
import 'registerScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(98, 221, 214, 1.0),
      appBar: AppBar(
        title: Image.asset('assets/images/Logo.png'),
        backgroundColor: Color.fromRGBO(98, 221, 214, 1.0),
        toolbarHeight: 600,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        )),
      ),
      body: Column(
        children: [
          Center(
            // Column is a widget that displays its children in a vertical array
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 90),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Fast delivery \nat your place',
                    style: TextStyle(
                      color: Color.fromRGBO(54, 91, 109, 1.0),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Add more widgets here
              ],
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Login();
              }));
            },
            child: const Text("Get Started"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Color.fromRGBO(54, 91, 109, 1.0),
              ),
            ),
          ),

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
        ],
      ),

//       bottomNavigationBar: BottomAppBar(
//   color: Color.fromRGBO(98, 221, 214, 1.0), // Background color
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       ElevatedButton(
//         onPressed: () {
//           Navigator.push(context, MaterialPageRoute(builder: (context) {
//             return Login();
//           }));
//         },
//         child: const Text("Get Started"),
//         style: ButtonStyle(
//           backgroundColor: MaterialStateProperty.all(
//             Color.fromRGBO(54, 91, 109, 1.0),
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
    );
  }
}
