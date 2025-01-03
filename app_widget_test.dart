import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobilfinalproje/main.dart';


class MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  group('MyHomePage Widget Test', () {
    late MockFirebaseService mockFirebaseService;

    setUp(() {
      mockFirebaseService = MockFirebaseService();
    });

    testWidgets('MyHomePage Widget Test', (WidgetTester tester) async {
      // MyApp'i başlat
      await tester.pumpWidget(MyApp());

      // LoginPage yerine MyHomePage'nin göründüğünü doğrula
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);

      // MyHomePage'deki ürün ekleyen düğmeyi bul ve tıkla
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Product ekranında olduğunu doğrula
      expect(find.text('Ürün Ekle'), findsOneWidget);
    });
  });

  group('LoginPage Widget Test', () {
    late MockFirebaseService mockFirebaseService;

    setUp(() {
      mockFirebaseService = MockFirebaseService();
    });

    testWidgets('LoginPage Widget Test', (WidgetTester tester) async {
      // MyApp'i başlat
      await tester.pumpWidget(MyApp());

      // MyHomePage yerine LoginPage'in göründüğünü doğrula
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);

      // Login ekranındaki e-posta ve şifre alanlarını doldur ve giriş düğmesini tıkla
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.byType(ElevatedButton).at(0));
      await tester.pump();

      // Giriş başarılı olursa MyHomePage'e yönlendirildiğini doğrula
      verify(mockFirebaseService.signInWithEmailAndPassword('test@example.com', 'password')).called(1);
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });
  });
}
