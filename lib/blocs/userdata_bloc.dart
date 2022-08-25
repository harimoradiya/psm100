import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  handleFavoriteIconClick(context, timestamp, uid) async {
    final DocumentReference userreference =
        firestore.collection('user').doc(uid);
    final DocumentReference timereference =
        firestore.collection('contents').doc(timestamp);

    DocumentSnapshot snapshot = await userreference.get();
    DocumentSnapshot timesnapshot = await timereference.get();

    List list = snapshot['loved items'];
    int _loves = timesnapshot['loves'];

    if (list.contains(timestamp)) {
      List a = [timestamp];
      await userreference.update({'loved items': FieldValue.arrayRemove(a)});
      timereference.update({'loves': _loves - 1});
    } else {
      list.add(timestamp);
      await userreference.update({'loved items': FieldValue.arrayUnion(list)});
      timereference.update({'loves': _loves + 1});
    }


    notifyListeners();
  }
}
