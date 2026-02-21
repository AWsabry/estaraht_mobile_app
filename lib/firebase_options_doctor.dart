// Flavor-specific Firebase options for the Doctor app.
// Android appId from android/app/src/doctor/google-services.json (com.owldots.estarhtapppro.doctor).
// For iOS: after adding the Doctor iOS app in Firebase, run `flutterfire configure`, select Doctor, then copy the ios options here.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DoctorFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DoctorFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DoctorFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DoctorFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DoctorFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlTGEMDNYlYMYAdxiegy5s_WdSOeELN0o',
    appId: '1:735559732305:android:888b56c0ae3965077fbc70',
    messagingSenderId: '735559732305',
    projectId: 'estaraht-84839',
    databaseURL: 'https://estaraht-84839-default-rtdb.firebaseio.com',
    storageBucket: 'estaraht-84839.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0O02e-nE4re1G-8oUytBjGPAKXNXhKsk',
    appId: '1:735559732305:ios:d680719e93297c0c7fbc70',
    messagingSenderId: '735559732305',
    projectId: 'estaraht-84839',
    databaseURL: 'https://estaraht-84839-default-rtdb.firebaseio.com',
    storageBucket: 'estaraht-84839.firebasestorage.app',
    iosBundleId: 'com.owldots.estarhtapppro.doctor',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyARNhCyvyNyBXPgmKLPBRBuAHK_Edg64fU',
    appId: '1:735559732305:web:f30c631efa22f7087fbc70',
    messagingSenderId: '735559732305',
    projectId: 'estaraht-84839',
    authDomain: 'estaraht-84839.firebaseapp.com',
    databaseURL: 'https://estaraht-84839-default-rtdb.firebaseio.com',
    storageBucket: 'estaraht-84839.firebasestorage.app',
    measurementId: 'G-X53CM40MD9',
  );
}
