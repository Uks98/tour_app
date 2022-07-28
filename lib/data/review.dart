import 'package:firebase_database/firebase_database.dart';

class Review {
  String? id;
  String? review;
  String? createTime;

  Review(this.id, this.review, this.createTime);

   Review.fromSnapshot(DataSnapshot snapshot){
    final data = snapshot.value as Map?;
    if(data != null) {
      id = data['id'];
    review = data['review'];
    createTime = data['createTime'];
    }
  }


  toJson() {
    return {
      'id': id,
      'review': review,
      'createTime': createTime,
    };
  }
}