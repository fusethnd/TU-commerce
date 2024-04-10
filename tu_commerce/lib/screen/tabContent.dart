import 'package:flutter/material.dart';

class TabContent extends StatelessWidget {
  final String content;

  TabContent(this.content);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            content,
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              // Add your logic here to show additional data when the button is clicked
            },
            child: Text('Show Additional Data'),
          ),
          // Add your additional data widgets here, initially hidden
        ],
      ),
    );
  }
}