import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallpaper/page/empty_page.dart';
import '../models/config.dart';
import '../widget/cached_image.dart';
import 'details_page.dart';

class CatagoryItem extends StatefulWidget {
  final String title;
  final String selectedCatagory;

  CatagoryItem({Key? key, required this.title, required this.selectedCatagory})
      : super(key: key);

  @override
  _CatagoryItemState createState() =>
      _CatagoryItemState(this.title, this.selectedCatagory);
}

class _CatagoryItemState extends State<CatagoryItem> {
  late String title;
  late String selectedCatagory;

  _CatagoryItemState(this.title, this.selectedCatagory);

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    _isLoading = true;
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late ScrollController controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _data = <DocumentSnapshot>[];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firestore
          .collection('contents')
          .where('category', isEqualTo: selectedCatagory)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    } else
      data = await firestore
          .collection('contents')
          .where('category', isEqualTo: selectedCatagory)
          .orderBy('timestamp', descending: true)
          .startAfter([(_lastVisible as dynamic)['timestamp']])
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
        const SnackBar(
          content: Text('No more data!'),
        ),
      );
    }
    return null;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        key: scaffoldKey,
        centerTitle: false,
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _data.length == 0 && _data.isEmpty
          ? EmptyPage(
              icon: FontAwesomeIcons.earlybirds,
              title: 'No data found.\n',
            )
          : Column(
              children: [
                Expanded(
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    controller: controller,
                    itemCount: _data.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < _data.length) {
                        final DocumentSnapshot d = _data[index];
                        return InkWell(
                          child: Stack(
                            children: <Widget>[
                              Hero(
                                  tag: 'category$index',
                                  child: cachedImage(d['image url'])),
                              Positioned(
                                bottom: 30,
                                left: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      Config().hashTag,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        d['category'],
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
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
                                        color: Colors.white.withOpacity(0.5),
                                        size: 25),
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
                                    builder: (context) => DetailsPage(
                                          tag: 'category$index',
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
                          child: Center(
                            child: new SizedBox(
                                width: 32.0,
                                height: 32.0,
                                child: CupertinoActivityIndicator()),
                          ),
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
            ),
    );
  }
}
