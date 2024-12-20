// import 'database_helper.dart';
//
// class UserRepo {
//   final int? id;
//   final String name;
//   final String email;
//   final String phone;
//   final String uid;
//
//   UserRepo({this.id, required this.name, required this.email, required this.phone, required this.uid});
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'uid': uid,
//     };
//   }
// }
//
// class UserRepository {
//   final dbHelper = DatabaseHelper();
//
//   Future<int> insertUser(UserRepo user) async {
//     try {
//       final db = await dbHelper.database;
//       return await db.insert('Users', user.toMap());
//     } catch (e) {
//       throw Exception('Failed to insert user: $e');
//     }
//   }
//
//   Future<List<UserRepo>> getAllUsers() async {
//     try {
//       final db = await dbHelper.database;
//       final List<Map<String, dynamic>> result = await db.query('Users');
//       return result.map((map) => UserRepo(
//         id: map['id'],
//         name: map['name'],
//         email: map['email'],
//         phone: map['phone'],
//         uid: map['uid'],
//       )).toList();
//     } catch (e) {
//       throw Exception('Failed to get users: $e');
//     }
//   }
//
//   Future<int> updateUser(UserRepo user) async {
//     try {
//       final db = await dbHelper.database;
//       return await db.update('Users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
//     } catch (e) {
//       throw Exception('Failed to update user: $e');
//     }
//   }
//
//   Future<int> deleteUser(int id) async {
//     try {
//       final db = await dbHelper.database;
//       return await db.delete('Users', where: 'id = ?', whereArgs: [id]);
//     } catch (e) {
//       throw Exception('Failed to delete user: $e');
//     }
//   }
// }