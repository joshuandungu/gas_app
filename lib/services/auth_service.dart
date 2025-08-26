import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gas/models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (userDoc.exists) {
          return UserModel.fromMap(userDoc.data()!);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<UserModel?> register(String fullName, String email, String password, String role) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final newUser = UserModel(
          id: credential.user!.uid,
          fullName: fullName,
          email: email,
          role: role,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(credential.user!.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}