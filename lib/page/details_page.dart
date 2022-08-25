import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fzwallpaper/fzwallpaper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wallpaper/blocs/data_bloc.dart';
import 'package:wallpaper/blocs/internet_bloc.dart';
import 'package:wallpaper/blocs/signin_bloc.dart';
import 'package:wallpaper/blocs/userdata_bloc.dart';
import 'package:wallpaper/models/config.dart';
import 'package:wallpaper/models/icon_data.dart';
import 'package:wallpaper/utils/circular_button.dart';
import 'package:wallpaper/utils/dialog.dart';

class DetailsPage extends StatefulWidget {
  final String tag;
  final String imageUrl;
  final String catagory;
  final String timestamp;

  DetailsPage(
      {Key? key,
      required this.tag,
      required this.imageUrl,
      required this.catagory,
      required this.timestamp})
      : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState(this.tag,this.imageUrl,this.catagory,this.timestamp);
}

class _DetailsPageState extends State<DetailsPage> {
  late String tag;
  late String imageUrl;
  late String catagory;
  late String timestamp;


  _DetailsPageState(this.tag, this.imageUrl, this.catagory, this.timestamp);

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String progress = 'Download';
  bool downloading = false;
  late Stream<String> progressString;
  Icon dropIcon = Icon(Icons.arrow_upward);
  Icon upIcon = Icon(Icons.arrow_upward);
  Icon downIcon = Icon(Icons.arrow_downward);
  PanelController pc = PanelController();
  late PermissionStatus status;

  void openSetDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(

            title: Center(child: Text("SET AS")),
            children: [
              ListTile(
                leading: circularButton(Icons.lock, Colors.grey[400]),
                title: Text("Set As Lock Screen"),
              ),
              ListTile(
                leading: circularButton(Icons.home, Colors.grey[400]),
                title: Text("Set As Home Screen"),
              ),
              ListTile(
                leading: circularButton(
                    Icons.screen_lock_rotation_rounded,Colors.grey[400]),
                title: Text("Set As Both Screen"),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    print('cancel');
                    Navigator.pop(context);

                  },
                  child: Text("Cancel"),
                ),
              )
            ],
          );
        });
  }

  _setLockSreen() {
    Platform.isIOS ?
        setState(() {
          progress = "iOs is not supported";
    }) : progressString = Fzwallpaper.imageDownloadProgress(imageUrl);
  }

  handleStoragePermission() async {
    await Permission.storage.request().then((_) async {
      if (await Permission.storage.status == Permission.storage.isGranted) {
        print('Permission granted');
      } else if (await Permission.storage.status ==
          Permission.storage.isDenied) {
        print('Permission denied');
      } else if (await Permission.storage.status ==
          Permission.storage.isPermanentlyDenied) {
        print('Permission permanently denied');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final DataBloc db = Provider.of<DataBloc>(context, listen: false);
    final panelHeightClosed = h * 0.09;

    return Scaffold(
        key: _scaffoldKey,
        body: SlidingUpPanel(
          controller: pc,
          color: Colors.white.withOpacity(0.9),
          minHeight: panelHeightClosed,
          maxHeight: 400,
          backdropEnabled: false,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18), topRight: Radius.circular(18)),
          body: panelBodyUI(h, w),
          panel: panelUI(db),
          onPanelClosed: () {
            setState(() {
              dropIcon = upIcon;
            });
          },
          onPanelOpened: () {
            setState(() {
              dropIcon = downIcon;
            });
          },
        ));
  }

  Widget panelBodyUI(h, w) {
    final SignInBloc signInBloc =
        Provider.of<SignInBloc>(context, listen: false);
    return Stack(
      children: <Widget>[
        Container(
          height: h,
          width: w,
          color: Colors.grey[200],
          child: Hero(
            tag: tag,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover)),
              ),
              placeholder: (context, url) => Icon(Icons.image),
              errorWidget: (context, url, error) =>
                  Center(child: Icon(Icons.error)),
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: 20,
          child: InkWell(
            child: Container(
                height: 40,
                width: 40,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: _buildLoveIcon(signInBloc.uid)),
            onTap: () {
              _loveIconPressed();
            },
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: InkWell(
            child: Container(
              height: 40,
              width: 40,
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.close,
                size: 25,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  Widget _buildLoveIcon(uid) {
    final sb = context.watch<SignInBloc>();
    if (sb.guestuser == false) {
      return StreamBuilder(
        stream: firestore.collection('user').doc(uid).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return IconSaved().greyIcon;
          List d = (snap.data as dynamic)['loved items'];
          if (d.contains(timestamp)) {
            return IconSaved().redICon;
          } else {
            return IconSaved().greyIcon;
          }
        },
      );
    } else {
      return IconSaved().greyIcon;
    }
  }

  _loveIconPressed() async {
    final sb = context.read<SignInBloc>();
    if (sb.guestuser == false) {
      context
          .read<UserBloc>()
          .handleFavoriteIconClick(context, timestamp, sb.uid);
    } else {
      await showGuestUserInfo(context);
    }
  }

  Widget panelUI(db) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: Container(
              padding: EdgeInsets.only(top: 10),
              width: double.infinity,
              child: buildDragHandle()
            ),

          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Config().hashTag,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      '$catagory',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                Spacer(),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.favorite,
                      color: Colors.red[600],
                      size: 22,
                    ),
                    StreamBuilder(
                      stream: firestore
                          .collection('contents')
                          .doc(timestamp)
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) return _buildLoves(0);
                        return _buildLoves((snap.data as dynamic)['loves']);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey.shade400,
                                  blurRadius: 10,
                                  offset: Offset(2, 2))
                            ]),
                        child: Icon(
                          Icons.wallpaper,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        final ib = context.read<InternetBloc>();
                        await context.read<InternetBloc>().checkInternet();
                        if (ib.hasInternet == false) {
                          setState(() {
                            progress = 'Check your internet connection!';
                          });
                        } else {
                          openSetDialog();
                        }
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Set Wallpaper',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey.shade400,
                                  blurRadius: 10,
                                  offset: Offset(2, 2))
                            ]),
                        child: Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        handleStoragePermission();
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Download',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 5,
                    height: 30,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      progress,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }

  Widget buildDragHandle() => GestureDetector(
    child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 30,
              height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(13)
            ),

          ),
        ),
    ),
    onTap: tooglePanel,

  );
  void tooglePanel() => pc.isPanelOpen() ? pc.close() : pc.open();



  Widget _buildLoves(loves) {
    return Text(
      loves.toString(),
      style: TextStyle(color: Colors.black54, fontSize: 16),
    );
  }
}
