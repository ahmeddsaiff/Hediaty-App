// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future<User?> signUp(String email, String password) async {
//     try {
//       final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return userCredential.user;
//     } catch (e) {
//       print("Error signing up: $e");
//       return null;
//     }
//   }
//
//   Future<User?> signIn(String email, String password) async {
//     try {
//       final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return userCredential.user;
//     } catch (e) {
//       print("Error signing in: $e");
//       return null;
//     }
//   }
//
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
//
//   User? getCurrentUser() {
//     return _auth.currentUser;
//   }
// }
