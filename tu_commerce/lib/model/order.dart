class Orders{
  Map<String, dynamic>? product;
  Map<String, dynamic>? buyer;
  DateTime? time;
  int status = 0;

  void updateStatus(){
    status++;
  }
}