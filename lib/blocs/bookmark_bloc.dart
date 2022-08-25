import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BookmarkBloc extends ChangeNotifier {

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<List> getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String _uid = sharedPreferences.getString('uid');


    final DocumentReference documentReference =  firebaseFirestore.collection('user').doc(_uid);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    List list = documentSnapshot['loved items'];
    List filteredData = [];
    if(list.isNotEmpty){
      await firebaseFirestore
          .collection('contents')
          .where('timestamp', whereIn: list)
          .get()
          .then((QuerySnapshot snap) {
        filteredData = snap.docs;
      });
    }
    notifyListeners();
    return filteredData;

  }

}