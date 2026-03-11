import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCWrQDlelc1w4inWPYJA9Exvw_djvnmRFs",
            authDomain: "flutter-tok.firebaseapp.com",
            projectId: "flutter-tok",
            storageBucket: "flutter-tok.appspot.com",
            messagingSenderId: "136146624285",
            appId: "1:136146624285:web:c1c65ffda4995386940bf4"));
  } else {
    await Firebase.initializeApp();
  }
}
