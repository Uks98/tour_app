import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:tourapp/data/listData.dart';

import '../../data/tourdata.dart';
import '../../tourDetailPage.dart';
class MapPage extends StatefulWidget {
  final DatabaseReference? databaseReference; //실시간 데이터 베이스 변수
  final Future<Database>? db; //내부에 저장되는 데이터베이스
  final String? id; //로그인한 id
   MapPage({Key? key,this.databaseReference,this.db,this.id}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<DropdownMenuItem<Item>> list = List.empty(growable: true);
  List<DropdownMenuItem<Item>>sublist = List.empty(growable: true);
  List<TourData> tourData = List.empty(growable: true);
  ScrollController scrollController = ScrollController();

  String authKey = "iwOI%2BU0JCUIMem0fddRQ9Y4Fj2E254wSmoXLGM3hVwqHiS8h12%2FqNozM62Kb5D4ihpeW4KWouAt%2B9djISlDJzw%3D%3D";

  Item? area;
  Item? kind;
  int page = 1;

  @override
  void initState() {
    print("아디 값 ${widget.id}");
    print("래퍼 값 ${widget.databaseReference}");
    // TODO: implement initState
    super.initState();
    list =  Area().seoulArea;
    sublist = Kind().kinds;

    area = list[0].value; //dropdown 버튼 클래스 기능 중 value값
    kind = sublist[0].value;
    print("아리아 : ${area}");
    print("카인드 : ${kind}");

    scrollController.addListener(() {
      if(scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange){
        page ++;
       getAreaList(area: area!.value,contentTypeId: kind!.value, page:page);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("검색하기"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  DropdownButton<Item>(value: area,items: list, onChanged: (value){
                  Item selectedItem = value!;
                  setState((){
                    area = selectedItem;
                  });
                  },),
                  SizedBox(width: 10,),
                  DropdownButton<Item>(items: sublist, onChanged: (value){
                    Item selectedItem = value!;
                    setState((){
                      kind = selectedItem;
                    });
                  },
                    value: kind,),//value는 선택된 값
                  SizedBox(width: 10,),
                  ElevatedButton(onPressed: (){
                    page = 1;
                    tourData.clear();
                    getAreaList(
                      area : area!.value,
                      contentTypeId: kind!.value,
                      page : page
                    );
                  }, child: Text("검색하기",style: TextStyle(color: Colors.white),),),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Expanded(child: ListView.builder(itemBuilder: (context,index){
                return Card(
                  child: InkWell(
                    child: Row(children: [Hero(tag: "tourinfo$index", child: Container(
                      margin: EdgeInsets.all(10),
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,width: 1,
                        ),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: getImage(tourData[index].imagePath),
                        ),
                      ),
                    ),),
                    SizedBox(width: 20,),
                      Container(child: Column(children: [
                        Text(tourData[index].title.toString(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        Text("주소 : ${tourData[index].address.toString()}"),
                        tourData[index].tel != null ? Text("전화번호 : ${tourData[index].tel.toString()}") : Container()
                      ],
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                  width: MediaQuery.of(context).size.width - 150,
                )
                    ],
                ),
                onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>TourDetailPage(
                        tourData : tourData[index],
                        index : index,
                        databaseReference : widget.databaseReference,
                        id: widget.id,
                      )));
                }
                  ),
                );
              },
              itemCount: tourData.length,
                controller: scrollController,
              ))
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ),
      ),
    );
  }
  void getAreaList({required int area, required int contentTypeId,required int page})async{
    var url = "http://api.visitkorea.or.kr/openapi/service/rest/KorService/areaBasedList?ServiceKey=$authKey&MobileOS=AND&MobileApp=ModuTour&_type=json&areaCode=1&numOfRows=10&sigunguCode=$area&pageNo=$page";
    if(contentTypeId != 0){
      //url = url + "$contentTypeId=$contentTypeId";
      url = url + '&contentTypeId=$contentTypeId';
    }
    var response = await http.get(Uri.parse(url));
    String body = utf8.decode(response.bodyBytes);
    final json = jsonDecode(body);
    if(json['response']['header']['resultCode'] == "0000"){
      if(json["response"]["body"]["items"] == ""){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: Text("마지막 데이터입니다."),
          );
        });
      }else{
        List jsonArray = json["response"]["body"]["items"]["item"];
        for(final x in jsonArray){
          setState((){
            tourData.add(TourData.fromJson(x));
          });
        }
      }
    }
  }
  ImageProvider getImage(String? imagePath) {
    if (imagePath != null) {
      return NetworkImage(imagePath);
    } else {
      return NetworkImage("https://item.kakaocdn.net/do/a1866850b14ae47d0a2fd61f409dfc057154249a3890514a43687a85e6b6cc82");
    }
  }
}
