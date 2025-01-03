import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobilfinalproje/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  group('Unit test', () {
    late FirebaseService firebaseService;

    setUpAll(() async {
      // Firebase'i başlat
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
    });

    setUp(() {
      // Her test öncesinde yeni bir FirebaseService örneği oluştur
      firebaseService = FirebaseService();
    });

    test('SignInWithEmailAndPassword başarı durumunda UserCredentialı döndürmelidir', () async {
      final result = await firebaseService.signInWithEmailAndPassword('beyzairem@gmail.com', '12345678');
      expect(result, isA<UserCredential>());
    });

    test('SignInWithEmailAndPassword başarısızlık durumunda null değerini döndürmelidir', () async {
      final result = await firebaseService.signInWithEmailAndPassword('beyzairem@gmailcom', 'fj38fw39');
      expect(result, isNull);
    });

    test('RegisterUser, başarı durumunda UserCredentialı döndürmelidir', () async {
      final result = await firebaseService.registerUser(email: 'beyzire@gmail.com', password: '185697');
      expect(result, isA<UserCredential>());
    });

    test('RegisterUser başarısızlık durumunda null değerini döndürmelidir', () async {
      final result = await firebaseService.registerUser(email: 'beyzairem@gmail.com', password: '12345678');
      expect(result, isNull);
    });
  });
}