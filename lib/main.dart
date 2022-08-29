import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wallpaper/blocs/bookmark_bloc.dart';
import 'package:wallpaper/blocs/data_bloc.dart';
import 'package:wallpaper/blocs/internet_bloc.dart';
import 'package:wallpaper/blocs/signin_bloc.dart';
import 'package:wallpaper/blocs/userdata_bloc.dart';
import 'package:wallpaper/page/home.dart';
import 'package:wallpaper/page/newsignin_page.dart';
import 'package:wallpaper/page/signin_page.dart';
import 'package:wallpaper/widget/drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DataBloc>(
          create: (context) => DataBloc(),
        ),
        ChangeNotifierProvider<SignInBloc>(
          create: (context) => SignInBloc(),
        ),
        ChangeNotifierProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        ChangeNotifierProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc(),
        ),
        ChangeNotifierProvider<InternetBloc>(
          create: (context) => InternetBloc(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
            appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
              color: Colors.white,
              textTheme: TextTheme(
                  headline6: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600)),
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
            ),
            textTheme: TextTheme(
                headline6: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            )),
          ),
          home: MyApp2()),
    );
  }
}

class MyApp2 extends StatelessWidget {
  const MyApp2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final signinbloc = context.watch<SignInBloc>();
    return signinbloc.isSignin == false && signinbloc.guestuser == false
        ? SignInPage(closeDialog: false)
        : HomePage();
  }
}

class MyStaggeredGridViewScreen extends StatefulWidget {
  @override
  _MyStaggeredGridViewScreenState createState() =>
      _MyStaggeredGridViewScreenState();
}

class _MyStaggeredGridViewScreenState extends State<MyStaggeredGridViewScreen> {
  List<String> listImages = [
    "https://images.unsplash.com/photo-1572537165377-627a37043464?ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8cGl4ZWx8ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1572204292164-b35ba943fca7?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8cGl4ZWx8ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1590254553792-7e91903c5357?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHBpeGVsfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1548586196-aa5803b77379?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTd8fHBpeGVsfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1572447454458-e68d82f828b3?ixid=MnwxMjA3fDB8MHxzZWFyY2h8ODd8fHBpeGVsfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1572204304559-b5f5380482c5?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTA4fHxwaXhlbHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1554516829-a3fce6ddbc6e?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTQzfHxwaXhlbHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1563642421748-5047b6585a4a?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTY2fHxwaXhlbHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1593439147804-c6c7656530ae?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MzUzfHxwaXhlbHxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1589953967596-442cf82a6d47?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80",
    "https://images.pexels.com/photos/1226302/pexels-photo-1226302.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.pexels.com/photos/1141792/pexels-photo-1141792.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/1366913/pexels-photo-1366913.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.pexels.com/photos/1097491/pexels-photo-1097491.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/719396/pexels-photo-719396.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.pexels.com/photos/3052361/pexels-photo-3052361.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.pexels.com/photos/1969979/pexels-photo-1969979.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.pexels.com/photos/274021/pexels-photo-274021.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.unsplash.com/photo-1516339901601-2e1b62dc0c45?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTF8fHdhbGxwYXBlcnN8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Staggered GridView',
        ),
        backgroundColor: Colors.black,
      ),
      drawer: DrawerWidget(),
      body: Container(
        margin: EdgeInsets.all(10),
        child: StaggeredGridView.countBuilder(
            mainAxisSpacing: 10,
            crossAxisSpacing: 8,
            crossAxisCount: 2,
            itemCount: listImages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: listImages[index],
                      fit: BoxFit.cover),
                ),
              );
            },
            staggeredTileBuilder: (index) {
              return StaggeredTile.count(1, index.isEven ? 1.4 : 1.9);
            }),
      ),
    );
  }
}
