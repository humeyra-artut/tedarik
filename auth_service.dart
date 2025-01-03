import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection("users");

  Future<void> registerUser({required String Email, required int Password}) async{
    await userCollection.doc().set({
    "Email" : Email,
    "Password" : Password,
    });
  }
}