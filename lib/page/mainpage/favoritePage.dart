import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/tourdata.dart';
import 'tourDetailPage.dart';

class FavoritePage extends StatefulWidget {
  final DatabaseReference databaseReference;
  final Future<Database> db;
  final String id;
  FavoritePage({Key? key,required this.databaseReference,required this.db,required this.id}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Future<List<TourData>>? _tourList;
  ImageProvider getImage(String? imagePath){
    if(imagePath != null) {
      return NetworkImage(imagePath);
    }else{
      return AssetImage('repo/images/map_location.png');
    }
  }
  void deleteTour(Future<Database> db, TourData info)async{
    final Database database = await db;
    await database.delete("place",where: "title = ?", whereArgs: [info.title]).then((value){
      setState((){
        _tourList = getTodos();
      });
    });
  }
  Future<List<TourData>> getTodos()async{
    final Database database = await widget.db;
    final maps = await database.query("place");
    print("maps : ${maps}");

    return List.generate(maps.length, (index) {
      return TourData(
          title: maps[index]["title"].toString(),
          tel: maps[index]['tel'].toString(),
          address: maps[index]['address'].toString(),
          zipcode: maps[index]['zipcode'].toString(),
          mapy: maps[index]['mapy'].toString(),
          mapx: maps[index]['mapx'].toString(),
          imagePath: maps[index]['imagePath'].toString());
    });
  }
  @override
  void initState() {
    super.initState();
    _tourList = getTodos();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('즐겨찾기'),
      ),
      body: Container(
        child: Center(
          child: FutureBuilder(
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return CircularProgressIndicator();
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                case ConnectionState.active:
                  return CircularProgressIndicator();
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        List<TourData> tourList = snapshot.data as List<TourData>;
                        TourData info = tourList[index];
                        return Card(
                          child: InkWell(
                            child: Row(
                              children: <Widget>[
                                Hero(
                                    tag: 'tourinfo$index',
                                    child: Container(
                                        margin: EdgeInsets.all(10),
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black, width: 1),
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: getImage(info.imagePath))))),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        info.title!,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('주소 : ${info.address}'),
                                      info.tel != 'null'
                                          ? Text('전화 번호 : ${info.tel}')
                                          : Container(),
                                    ],
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                  ),
                                  width:
                                  MediaQuery.of(context).size.width - 150,
                                )
                              ],
                            ),
                            onTap: () {
                              // 상세페이지 이동은 TourDetailPage를 재사용하도록 합니다
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TourDetailPage(
                                    id: widget.id,
                                    tourData: info,
                                    index: index,
                                    databaseReference:
                                    widget.databaseReference,
                                  )));
                            },
                            onDoubleTap: (){
                              deleteTour(widget.db, info);
                            },
                          ),
                        );
                      },
                      itemCount: (snapshot.data! as List<TourData>).length,
                    );
                  } else {
                    return Text('No data');
                  }
              }
              return CircularProgressIndicator();
            },
            future: _tourList,
          ),
        ),
      ),
    );
  }
}
