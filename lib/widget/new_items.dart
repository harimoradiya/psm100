import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/config.dart';
import '../page/details_page.dart';
import 'cached_image.dart';


class NewItems extends StatefulWidget {
  NewItems({Key? key}) : super(key: key);

  @override
  _NewItemsState createState() => _NewItemsState();
}

class _NewItemsState extends State<NewItems> with AutomaticKeepAliveClientMixin {



  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late ScrollController controller;
  late DocumentSnapshot _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _data = <DocumentSnapshot>[];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection('contents')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    else
      data = await firestore
          .collection('contents')
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible['timestamp']])
          .limit(10)
          .get();

    if (data != null && data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _data.addAll(data.docs);
        });
      }
    } else {
      setState(() => _isLoading = false);
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('No more wallpapers!'),
        ),
      );
    }
    return null;
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }



  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: StaggeredGridView.countBuilder(
            controller: controller,
            crossAxisCount: 4,
            itemCount: _data.length + 1,
            itemBuilder: (BuildContext context, int index){

            if(index < _data.length) {
              final DocumentSnapshot d = _data[index];
              return InkWell(
                child: Stack(
                  children: <Widget>[
                    Hero(
                        tag: 'new$index',
                        child: cachedImage(d['image url'])),
                    Positioned(
                      bottom: 30,
                      left: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Config().hashTag,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            d['category'],
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 20,
                      child: Row(
                        children: [
                          Icon(Icons.favorite,
                              color: Colors.white.withOpacity(0.5), size: 25),
                          Text(
                            d['loves'].toString(),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailsPage(
                                tag: 'new$index',
                                imageUrl: d['image url'],
                                catagory: d['category'],
                                timestamp: d['timestamp'],
                              )));
                },
              );
            }

            return Center(
                      child: new Opacity(
                        opacity: _isLoading ? 1.0 : 0.0,
                        child: new SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: CupertinoActivityIndicator()),
                      ),
                    );


            },

            staggeredTileBuilder: (int index) =>
                new StaggeredTile.count(2, index.isEven ? 4 : 3),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: EdgeInsets.all(15),
          ),

        ),

      ],

    );
  }

  @override
  bool get wantKeepAlive => true;




}
