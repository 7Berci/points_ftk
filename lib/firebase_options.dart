// firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCvDdkEw07faIC97CQWs3GtFM6pblIaiGY',
    appId: '1:842557104070:web:0d007c7a5bfd234213dcc7',
    messagingSenderId: '842557104070',
    projectId: 'points-ftk',
    authDomain: 'points-ftk.firebaseapp.com',
    storageBucket: 'points-ftk.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvDdkEw07faIC97CQWs3GtFM6pblIaiGY',
    appId: '1:842557104070:android:0d007c7a5bfd234213dcc7',
    messagingSenderId: '842557104070',
    projectId: 'points-ftk',
    storageBucket: 'points-ftk.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvDdkEw07faIC97CQWs3GtFM6pblIaiGY',
    appId: '1:842557104070:ios:0d007c7a5bfd234213dcc7',
    messagingSenderId: '842557104070',
    projectId: 'points-ftk',
    storageBucket: 'points-ftk.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCvDdkEw07faIC97CQWs3GtFM6pblIaiGY',
    appId: '1:842557104070:ios:0d007c7a5bfd234213dcc7',
    messagingSenderId: '842557104070',
    projectId: 'points-ftk',
    storageBucket: 'points-ftk.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCvDdkEw07faIC97CQWs3GtFM6pblIaiGY',
    appId: '1:842557104070:web:0d007c7a5bfd234213dcc7',
    messagingSenderId: '842557104070',
    projectId: 'points-ftk',
    storageBucket: 'points-ftk.appspot.com',
  );
}
