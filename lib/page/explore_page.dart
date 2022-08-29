import 'package:flutter/material.dart';

import '../widget/new_items.dart';
import '../widget/popular_items.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {

  var _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Explore",
        style: TextStyle(color: Colors.black),),
        bottom: PreferredSize(preferredSize: Size.fromHeight(60),
            child: Container(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TabBar(
                    controller: tabController,
                    tabs: <Widget>[
                      Tab(
                        child: Text('Popular'),
                      ),
                      Tab(
                        child: Text(
                          'New Arrived',
                        ),
                      )
                    ],
                    labelColor: Colors.black,
                    indicatorColor: Colors.grey[900],
                    unselectedLabelColor: Colors.grey,
                  ),
                ),
              ),

        ),

      ),
      ),

      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                PopularItems(),
                NewItems()

              ],
            ),
          ),
          // Align(
          //   alignment: Alignment(0, 1.0),
          //   child: Container(
          //     color: Colors.deepPurpleAccent,
          //     child: facebookBannerAd,
          //   ),
          // ),
        ],
      ),
    );
  }
}
