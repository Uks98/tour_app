import 'package:flutter/material.dart';

class Item{
  String title;
  int value;
  Item(this.title,this.value);
}

class Area{
  List<DropdownMenuItem<Item>> seoulArea = List.empty(growable: true);
  Area(){seoulArea.add(DropdownMenuItem(child: Text("강남구"), value: Item("강남구",1)),);
    seoulArea.add(DropdownMenuItem(
      child: Text('강동구'),
      value: Item('강동구', 2),
    ),
    );
  seoulArea.add(DropdownMenuItem(child: Text("영도구"), value: Item("영도구",4)),);
  }
}

class Kind{
  List<DropdownMenuItem<Item>> kinds = List.empty(growable: true);

  Kind(){
    kinds.add(DropdownMenuItem(child: Text("관광지"),
      value: Item("관광지",12),),
    );
    kinds.add(DropdownMenuItem(
      child: Text('문화시설'),
      value: Item('문화시설', 14),
    ));
  }
}