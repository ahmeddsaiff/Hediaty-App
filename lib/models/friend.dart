// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Friend {
//   final String id;
//   final String name;
//   final String phone;
//
//   Friend({required this.id, required this.name, required this.phone});
//
//   factory Friend.fromDocument(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return Friend(
//       id: doc.id,
//       name: data['name'] ?? 'N/A',
//       phone: data['phone'] ?? 'N/A',
//     );
//   }
// }