// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZIMojkpE7OXQep2Kst3g6uL8hIF8A88M',
    appId: '1:53017535114:web:fd27a85d054f870ffac373',
    messagingSenderId: '53017535114',
    projectId: 'wisma1',
    authDomain: 'wisma1.firebaseapp.com',
    storageBucket: 'wisma1.appspot.com',
    measurementId: 'G-0186XESSE4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDU6AyOaCRiNdSo_G7BwpQw8M_JCgg99zg',
    appId: '1:53017535114:android:cb87366950f17329fac373',
    messagingSenderId: '53017535114',
    projectId: 'wisma1',
    storageBucket: 'wisma1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBLGItl2ru2I14b288MD2wU_S79vbjPuNI',
    appId: '1:53017535114:ios:960ec19e3b34a50bfac373',
    messagingSenderId: '53017535114',
    projectId: 'wisma1',
    storageBucket: 'wisma1.appspot.com',
    iosBundleId: 'com.example.wisma1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBLGItl2ru2I14b288MD2wU_S79vbjPuNI',
    appId: '1:53017535114:ios:960ec19e3b34a50bfac373',
    messagingSenderId: '53017535114',
    projectId: 'wisma1',
    storageBucket: 'wisma1.appspot.com',
    iosBundleId: 'com.example.wisma1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCZIMojkpE7OXQep2Kst3g6uL8hIF8A88M',
    appId: '1:53017535114:web:045a15bba9533efdfac373',
    messagingSenderId: '53017535114',
    projectId: 'wisma1',
    authDomain: 'wisma1.firebaseapp.com',
    storageBucket: 'wisma1.appspot.com',
    measurementId: 'G-0TKJ5LV9EG',
  );
}