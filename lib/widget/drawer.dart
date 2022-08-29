import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper/blocs/signin_bloc.dart';
import 'package:wallpaper/page/bookmark_page.dart';
import 'package:wallpaper/page/categories_page.dart';
import 'package:wallpaper/page/explore_page.dart';
import 'package:wallpaper/page/signin_page.dart';
import 'package:wallpaper/utils/snacbar.dart';

import '../models/config.dart';
import '../utils/next_screen.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key? key}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var textCtrl = TextEditingController();

  final List title = [
    'Categories',
    'Explore',
    'Saved Items',
    'About App',
    'Rate & Review',
    'Privacy Policy',
    'Logout'
  ];

  final List icons = [
    Icons.category_outlined,
    FontAwesomeIcons.image,
    Icons.favorite,
    Icons.info,
    Icons.star,
    Icons.privacy_tip_outlined,
    Icons.logout
  ];

  Future openLogoutDialog(context1) async {
    const snackBar = SnackBar(
      content: Text('Sorry, You are guest user!'),
    );
    showDialog(
        context: context1,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Logout?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Text('Do you really want to Logout?'),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  final sb = context.read<SignInBloc>();
                  if(sb.isSignin == true) {
                    Navigator.pop(context);
                    sb.userSignOut().then((_) =>
                        nextScreenCloseOthers(
                            context, SignInPage(closeDialog: false,)));
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.pop(context);
                  }
                },
              ),
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                  print("Stay");
                },
              )
            ],
          );
        });
  }

  aboutAppDialog() {
    showDialog(
        context: context,
        builder: (BuildContext coontext) {
          return AboutDialog(
            applicationName: 'PSM100',
            applicationVersion: '1.112.1412',
            applicationIcon: Image(
              height: 40,
              width: 40,
              image: AssetImage(Config().appIconmain),
            ),
            applicationLegalese: 'Hari Moradiya',
          );
        });
  }

  void handleRating() {
    LaunchReview.launch(
        androidAppId: Config().packageName, iOSAppId: null, writeReview: true);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 50, left: 0),
                alignment: Alignment.center,
                height: 150,
                child: Text(
                  "PSM100",
                  // Config().hashTag.toUpperCase(),
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: title.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Container(
                        height: 45,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                icons[index],
                                color: Colors.grey,
                                size: 22,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(title[index],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (index == 0) {
                          nextScreeniOS(context, CategoriesPage());
                        } else if (index == 1) {
                          nextScreeniOS(context, ExplorePage());
                        } else if (index == 2) {

                          nextScreeniOS(context, BookMarkPage());
                        } else if (index == 3) {
                          aboutAppDialog();
                        } else if (index == 4){
                          handleRating();
                        }
                        else if(index ==5){
                          print('$index');
                        }
                        else if(index ==6){
                          //Navigator.pop(context);
                          openLogoutDialog(context);
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              ),
              // Column(
              //   children: [
              //     Column(
              //       children: [
              //         Divider(),
              //         InkWell(
              //           child: Container(
              //             height: 45,
              //             child: Padding(
              //               padding: const EdgeInsets.only(left: 15),
              //               child: Row(
              //                 children: <Widget>[
              //                   Icon(
              //                     Icons.logout,
              //                     color: Colors.grey,
              //                     size: 22,
              //                   ),
              //                   SizedBox(
              //                     width: 20,
              //                   ),
              //                   Text('Logout',
              //                       style: TextStyle(
              //                           fontSize: 16,
              //                           fontWeight: FontWeight.w500))
              //                 ],
              //               ),
              //             ),
              //           ),
              //           onTap: () {
              //             Navigator.pop(context);
              //             openLogoutDialog(context);
              //           },
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ],
          )),
    );
  }
}
