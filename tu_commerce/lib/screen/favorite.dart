import 'package:flutter/material.dart';
import 'package:tu_commerce/function/Firebase.dart';

class Favorite extends StatefulWidget {
  final Map<String, dynamic>  username;
  
  Favorite({Key? key, required this.username}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {

  void updateFavoriteStatus(int index,) async {
    List<dynamic>? favorites;


    favorites = await updateUser(widget.username, widget.username['favorite'][index],'remove');

    setState(() {
      widget.username['favorite'] = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites'),),
      body: ListView.builder(
          itemCount: widget.username['favorite'].length,
          itemBuilder: (context,index){

            String? imageUrl = widget.username['favorite'][index]['link'];
            print(imageUrl);
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Image.network(imageUrl!),
                ),
                title: Text(widget.username['favorite'][index]['prodName'].toString()),
                subtitle: Row(
                  children: [
                    Text(widget.username['favorite'][index]['price'].toString()),
                    SizedBox(width: 8,),
                    ElevatedButton(
                      onPressed: (){
                        updateFavoriteStatus(index);
                      }, 
                      child: Icon(Icons.favorite),)
                  ],
                ),
              ),
            );
          }
        )
      
    );
  }
}
