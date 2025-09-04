import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDkWquvWKZKPc6bmS-HBvn_zC-SJgnvkMY",
            authDomain: "balanced-meal-414be.firebaseapp.com",
            projectId: "balanced-meal-414be",
            storageBucket: "balanced-meal-414be.firebasestorage.app",
            messagingSenderId: "47749609188",
            appId: "1:47749609188:web:8f607cfea1a0edfc0adef1",
            measurementId: "G-VWGDHXJQG3"));
  } else {
    await Firebase.initializeApp();
  }
}
