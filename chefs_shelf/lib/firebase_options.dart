
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'As opções padrão do Firebase não foram configuradas para a web.'
        'Você pode reconfigurar isso executando o FlutterFire CLI novamente.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'As opções padrão do Firebase não foram configuradas para iOS - '
          'Você pode reconfigurar isso executando o FlutterFire CLI novamente.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'As opções padrão do Firebase não foram configuradas para macOS - '
          'Você pode reconfigurar isso executando o FlutterFire CLI novamente.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'As opções padrão do Firebase não foram configuradas para Windows - '
          'Você pode reconfigurar isso executando o FlutterFire CLI novamente.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'As opções padrão do Firebase não foram configuradas para Linux - '
          'Você pode reconfigurar isso executando o FlutterFire CLI novamente.',
        );
      default:
        throw UnsupportedError(
          'As opções padrão do Firebase não são suportadas para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5g5wivZN2lfni_XpIDJYHuY3O7gKDHVs',
    appId: '1:960049539413:android:c848629d7047f14603e7dc',
    messagingSenderId: '960049539413',
    projectId: 'chefs-shelf-37519',
    storageBucket: 'chefs-shelf-37519.firebasestorage.app',
  );
}
