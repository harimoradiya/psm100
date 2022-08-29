import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInBloc extends ChangeNotifier {
  SignInBloc() {
    checkSignIn();
    checkGuestUser();
  }
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _guestuser = false;

  bool get guestuser => _guestuser;
  bool _isSignin = false;

  bool get isSignin => _isSignin;
  bool _hasError = false;

  bool get hasError => _hasError;
  late String _errorCode;

  String get errorCode => _errorCode;
  late String _name;

  String get name => _name;
  late String _uid;

  String get uid => _uid;
  late String _email;

  String get email => _email;
  String? _imageUrl;

  String? get imageUrl => _imageUrl;
  late String timestamp;

  Future signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await googleSignIn
        .signIn()
        .catchError((error) => print('error: $error'));
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleUser.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final User user =
            (await firebaseAuth.signInWithCredential(authCredential)).user;

        this._name = user.displayName;
        this._imageUrl = user.photoURL;
        this._email = user.email;
        this._uid = user.uid;
        _hasError = false;
        notifyListeners();
      } catch (e) {
        _hasError = true;
        // _errorCode = e.code;
        notifyListeners();
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  //check user is exist or not
  Future<bool> checkUserExist() async {
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection('user').doc(_uid).get();

    if (documentSnapshot.exists) {
      print('User exist');
      return true;
    } else {
      print('User does not exist');
      return false;
    }
  }

  Future saveToFirebase() async {
    final DocumentReference documentReference =
        firebaseFirestore.collection('user').doc(uid);
    await documentReference.set({
      'name': _name,
      'email': _email,
      'uid': _uid,
      'image url': _imageUrl,
      'timestamp': timestamp,
      'loved items': []
    });
  }

  Future getTimestamp() async {
    DateTime now = DateTime.now();
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    timestamp = _timestamp;
  }

  //get data from sharedpreference
  Future getUserDataFromSP() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _name = sharedPreferences.getString('name');
    _email = sharedPreferences.getString('email');
    _imageUrl = sharedPreferences.getString('image url');
    _uid = sharedPreferences.getString('uid');
    notifyListeners();
  }

  Future saveDataToSP() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('name', _name);
    await sharedPreferences.setString('email', _email);
    await sharedPreferences.setString('image url', _imageUrl);
    await sharedPreferences.setString('uid', _uid);
  }

  Future getUserDataFromFirebase(uid) async {
    await firebaseFirestore
        .collection('user')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snap) {
      this._uid = snap['uid'];
      this._name = snap['name'];
      this._email = snap['email'];
      this._imageUrl = snap['image url'];
      debugPrint("name: $_name, Image Url: $imageUrl ");
    });
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool('signed in', true);
    _isSignin = true;
    notifyListeners();
  }

  void checkSignIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _isSignin = sharedPreferences.getBool('signed in') ?? false;
    notifyListeners();
  }

  Future userSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    _isSignin = false;
    _guestuser = false;
    clearAllData();
    notifyListeners();
  }

  Future setGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest user', true);
    _guestuser = true;
    notifyListeners();
  }

  void checkGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _guestuser = sp.getBool('guest user') ?? false;
    notifyListeners();
  }

  Future clearAllData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  Future guestSignout() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest user', false);
    _guestuser = false;
    notifyListeners();
  }

  Future<int> getTotalUserCount() async {
    final String fieldName = 'count';
    final DocumentReference documentReference =
        firebaseFirestore.collection('item_count').doc('users_count');
    DocumentSnapshot snap = await documentReference.get();
    if (snap.exists == true) {
      int itemCount = snap[fieldName] ?? 0;
      return itemCount;
    } else {
      await documentReference.set({fieldName: 0});
      return 0;
    }
  }

  Future increaseUserCount() async {
    await getTotalUserCount().then((int documentCount) async {
      await firebaseFirestore
          .collection('item_count')
          .doc('users_count')
          .update({'count': documentCount + 1});
    });
  }
}
