
import 'package:firebase_database/firebase_database.dart';

class User{
  String? key;
  String? id;
  String? pw;
  String? createTime;

  User(this.id,this.pw,this.createTime);

  User.fromSnapShot(DataSnapshot snapshot){
    final data = snapshot.value as Map?;
    if(data != null) {
      key = snapshot.key.toString();
      id = data["id"];
      pw = data["pw"];
      createTime = data["createTime"];
    }
  }
  Map<String,dynamic> toMap(){
    return{
      "id" : id,
      "pw" : pw,
      "createTime":createTime
    };
  }

}