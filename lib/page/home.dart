import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:wallpaper/blocs/signin_bloc.dart';
import 'package:wallpaper/page/categories_page.dart';
import 'package:wallpaper/page/explore_page.dart';
import 'package:wallpaper/page/internet.dart';
import 'package:wallpaper/utils/dialog.dart';
import '../blocs/data_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../models/config.dart';
import '../utils/snacbar.dart';
import '../widget/drawer.dart';
import '../widget/loading_animation.dart';
import 'bookmark_page.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int listIndex = 0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future getData() async {
    Future.delayed(Duration(milliseconds: 0)).then((f) {
      final sb = context.read<SignInBloc>();
      final db = context.read<DataBloc>();
      sb
          .getUserDataFromSP()
          .then((value) => db.getData())
          .then((value) => db.getCategories());
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final db = context.watch<DataBloc>();
    final ib = context.watch<InternetBloc>();
    final sb = context.watch<SignInBloc>();

    return ib.hasInternet == false
        ? NoInternetPage()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: DrawerWidget(),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      height: 70,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.bars,
                              size: 20,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                          Text(
                            "PSM100",
                            style: TextStyle(
                                fontSize: 26,
                                color: Colors.black,
                                fontWeight: FontWeight.w200),
                          ),
                          Spacer(),
                          InkWell(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(!context
                                                  .watch<SignInBloc>()
                                                  .isSignin ||
                                              context
                                                      .watch<SignInBloc>()
                                                      .imageUrl ==
                                                  null
                                          ? Config().guestUserImage
                                          : context
                                              .watch<SignInBloc>()
                                              .imageUrl))),
                            ),
                            onTap: () {
                              !sb.isSignin
                                  ? showGuestUserInfo(context)
                                  : showUserInfo(
                                      context, sb.name, sb.email, sb.imageUrl);
                            },
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      )),
                  Stack(
                    children: <Widget>[
                      CarouselSlider(
                        options: CarouselOptions(
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            initialPage: 0,
                            viewportFraction: 0.90,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            height: h * 0.80,
                            autoPlay: true,
                            onPageChanged: (int index, reason) {
                              setState(() => listIndex = index);
                            }),
                        items: db.alldata.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return
                                  Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 0),
                                child: InkWell(
                                  child: CachedNetworkImage(
                                    imageUrl: i['image url'],
                                    imageBuilder: (context, imageProvider) =>
                                        Hero(
                                      tag: i['timestamp'],
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                            bottom: 50),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  blurRadius: 30,
                                                  offset: Offset(5, 20))
                                            ],
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover)),
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30, bottom: 40,right: 10,
                                            top:15),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      Config().hashTag,
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),

                                                    SizedBox(
                                                      width: 180,
                                                      child: Text(
                                                        i['category'],
                                                        overflow: TextOverflow.ellipsis,
                                                        softWrap: false,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Spacer(),
                                                Icon(

                                                  Icons.favorite,
                                                  size: 25,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  i['loves'].toString(),
                                                  style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                )
                                              ],
                                            )),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        LoadingWidget(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      size: 40,
                                    ),
                                  ),
                                  onTap: () {
                                    print('Moved to the details page');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DetailsPage(
                                                tag: i['timestamp'],
                                                imageUrl: i['image url'],
                                                catagory: i['category'],
                                                timestamp: i['timestamp'])));
                                  },
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),

                      Positioned(
                        top: 40,
                        left: w * 0.23,
                        child: Text(
                          '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: w * 0.34,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: DotsIndicator(
                            dotsCount: 5,
                            position: listIndex.toDouble(),
                            decorator: DotsDecorator(
                              activeColor: Colors.blueAccent,
                              color: Colors.grey[300],
                              spacing: EdgeInsets.all(3),
                              size: const Size.square(8.0),
                              activeSize: const Size(18.0, 9.0),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    height: 50,
                    width: w * 0.80,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(FontAwesomeIcons.dashcube,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CategoriesPage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidCompass,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ExplorePage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidHeart,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookMarkPage()));
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          );
  }
}
