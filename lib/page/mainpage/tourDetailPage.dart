// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
// import 'data/review.dart';
// import 'data/tourdata.dart';
//
// class TourDetailPage extends StatefulWidget {
//   final TourData? tourData;
//   final int? index;
//   final DatabaseReference? databaseReference;
//   final String? id;
//   TourDetailPage({Key? key,required this.tourData, required this.index, required this.databaseReference, required this.id}) : super(key: key);
//
//   @override
//   State<TourDetailPage> createState() => _TourDetailPageState();
// }
//
// class _TourDetailPageState extends State<TourDetailPage> {
//   List<Review> review = [];
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if(widget.databaseReference != null){
//       widget.databaseReference!.child("tour").child(widget.tourData!.id.toString()).child("review").onChildAdded.listen((event) {
//         if(event.snapshot.value != null){
//           setState((){
//             review.add(Review.fromSnapshot(event.snapshot));
//           });
//         }
//       });
//     }
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }


import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/disableInfo.dart';
import '../../data/review.dart';
import '../../data/tourdata.dart';

class TourDetailPage extends StatefulWidget {
  final TourData? tourData;
  final int? index;
  final DatabaseReference? databaseReference;
  final String? id;

  TourDetailPage({required this.tourData, required this.index, required this.databaseReference, required this.id});

  @override
  State<StatefulWidget> createState() => _TourDetailPage();
}

class _TourDetailPage extends State<TourDetailPage> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = {};
  CameraPosition? _GoogleMapCamera;
  TextEditingController? _reviewTextController = TextEditingController();
  Marker? marker;
  List<Review> reviews = List.empty(growable: true);
  bool _disableWidget = false;
  DisableInfo? _disableInfo;
  double disableCheck1 = 0;
  double disableCheck2 = 0;

  @override
  void initState() {
    super.initState();
    if(widget.databaseReference != null){
      widget.databaseReference!
          .child("tour")
          .child(widget.tourData!.id.toString())
          .child('review').onChildAdded
          .listen((event) {
        if(event.snapshot.value != null) {
          setState(() {
            reviews.add(Review.fromSnapshot(event.snapshot));
          });
        }else{
          return print("error in null");
        }
      });
    }
    _GoogleMapCamera = CameraPosition(
      target: LatLng(double.parse(widget.tourData!.mapy.toString()),
          double.parse(widget.tourData!.mapx.toString())),
      zoom: 16,
    );
    MarkerId markerId = MarkerId(widget.tourData.hashCode.toString());
    marker = Marker(
      icon:BitmapDescriptor.defaultMarkerWithHue(10.0),
        position: LatLng(double.parse(widget.tourData!.mapy.toString()),
            double.parse(widget.tourData!.mapx.toString())),
        flat: true,
        markerId: markerId);
    markers[markerId] = marker!;
    getDisableInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${widget.tourData!.title}',
                style: TextStyle(color: Colors.white, fontSize: 40),
              ),
              centerTitle: true,
              titlePadding: EdgeInsets.only(top: 10),
            ),
            pinned: true,
            backgroundColor: Colors.deepOrangeAccent,
          ),
          SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Hero(
                            tag: 'tourinfo${widget.index}',
                            child: Container(
                                width: 300.0,
                                height: 300.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                    Border.all(color: Colors.black, width: 1),
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: getImage(widget.tourData!.imagePath)
                                      ,)))),
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: Text(
                            widget.tourData!.address!,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        getGoogleMap(),
                        _disableWidget == false ? setDisableWidget() : showDisableWidget() ,
                        //  reviewWidget()
                      ],
                    ),
                  ),
                ),
              ])),
          SliverPersistentHeader(
            delegate: _HeaderDelegate(
                minHeight: 50,
                maxHeight: 30,
                child: Container(
                  color: Colors.lightBlueAccent,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          '??????',
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                )),
            pinned: true,
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Card(
                  child: InkWell(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                      child: Text(
                        '${reviews[index].id} : ${reviews[index].review}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    onDoubleTap: (){
                      if(reviews[index].id == widget.id){
                        widget.databaseReference!
                            .child('tour')
                            .child(widget.tourData!.id.toString())
                            .child('review').child(widget.id!)
                            .remove();
                        setState(() {
                          reviews.removeAt(index);
                        });
                      }
                    },
                  ),
                );
              }, childCount: reviews.length)),
          SliverList(
              delegate: SliverChildListDelegate([
                MaterialButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('?????? ??????'),
                            content: TextField(
                              controller: _reviewTextController,
                            ),
                            actions: <Widget>[
                              MaterialButton(
                                  onPressed: () {
                                    if(widget.databaseReference != null && widget.id != null && _reviewTextController!.text.isNotEmpty){
                                      Review review = Review(
                                          widget.id!,
                                          _reviewTextController!.text,
                                          DateTime.now().toIso8601String());
                                          widget.databaseReference!
                                          .child('tour')
                                          .child(widget.tourData!.id.toString())
                                          .child('review').child(widget.id!)
                                          .set(review.toJson());
                                    }
                                    Navigator.of(context).maybePop();
                                  },
                                  child: Text('?????? ??????')),
                              MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('????????????')),
                            ],
                          );
                        });
                  },
                  child: Text('?????? ??????'),
                )
              ]))
        ],
      ),
    );
  }

  getDisableInfo() {
    if(widget.databaseReference != null){
      widget.databaseReference!
          .child('tour')
          .child(widget.tourData!.id.toString())
          .onValue
          .listen((event) {
        _disableInfo = DisableInfo.fromSnapshot(event.snapshot);
        if (_disableInfo!.id == null) {
          setState(() {
            _disableWidget = false;
          });
        } else {
          setState(() {
            _disableWidget = true;
          });
        }
      });
    }

  }

  ImageProvider getImage(String? imagePath){
    if(imagePath != null) {
      return NetworkImage(imagePath);
    }else{
      return AssetImage('repo/images/map_location.png');
    }
  }

  Widget setDisableWidget() {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Text('???????????? ????????????. ??????????????????'),
            Text('?????? ????????? ?????? ?????? :  ${disableCheck1.floor()}'),
            Padding(
              padding: EdgeInsets.all(20),
              child: Slider(
                  value: disableCheck1,
                  min: 0,
                  max: 10,
                  onChanged: (value) {
                    setState(() {
                      disableCheck1 = value;

                    });
                    print(disableCheck1);
                  }),
            ),
            Text('?????? ????????? ?????? ?????? : ${disableCheck2.floor()}'),
            Padding(
              padding: EdgeInsets.all(20),
              child: Slider(
                  value: disableCheck2,
                  min: 0,
                  max: 10,
                  onChanged: (value) {
                    setState(() {
                      disableCheck2 = value;
                    });
                  }),
            ),
            MaterialButton(
              onPressed: () {
                DisableInfo info = DisableInfo(widget.id ,disableCheck1.floor(),
                    disableCheck2.floor(), DateTime.now().toIso8601String());
                if(widget.databaseReference != null){
                  widget.databaseReference!
                      .child("tour")
                      .child(widget.tourData!.id.toString())
                      .set(info.toJson())
                      .then((value) {
                    setState(() {
                      _disableWidget = true;
                    });
                  });
                }
              },
              child: Text('????????? ????????????'),
            )
          ],
        ),
      ),
    );
  }

  getGoogleMap() {
    return SizedBox(
      height: 400,
      width: MediaQuery.of(context).size.width - 50,
      child: GoogleMap(
          scrollGesturesEnabled: true,
          mapType: MapType.terrain,
          initialCameraPosition: _GoogleMapCamera!,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(markers.values)),
    );
  }

  showDisableWidget() {
    return Center(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.accessible , size: 40, color: Colors.orange),
              Text('?????? ?????? ?????? ?????? : ${_disableInfo!.disable2}' ,style: TextStyle(fontSize: 20),)
            ],mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Icon(Icons.remove_red_eye, size: 40 , color: Colors.orange,),
              Text('?????? ?????? ?????? ?????? : ${_disableInfo!.disable1}',style: TextStyle(fontSize: 20))
            ],mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          SizedBox(
            height: 20,
          ),
          Text('?????????  : ${_disableInfo!.id}'),
          SizedBox(
            height: 20,
          ),
          MaterialButton(onPressed: (){
            setState(() {
              _disableWidget = false;
            });
          } , child: Text('?????? ????????????'),)
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final double? minHeight;
  final double? maxHeight;
  final Widget? child;

  _HeaderDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => math.max(maxHeight!, minHeight!);

  @override
  double get minExtent => minHeight!;

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}