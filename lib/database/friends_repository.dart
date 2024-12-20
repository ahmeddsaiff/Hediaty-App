// import 'database_helper.dart';
//
// class Friend {
//   final int userId;
//   final int friendId;
//
//   Friend({required this.userId, required this.friendId});
//
//   Map<String, dynamic> toMap() {
//     return {
//       'user_id': userId,
//       'friend_id': friendId,
//     };
//   }
// }
//
// class FriendsRepository {
//   final dbHelper = DatabaseHelper();
//
//   Future<int> insertFriend(Friend friend) async {
//     final db = await dbHelper.database;
//     return await db.insert('Friends', friend.toMap());
//   }
//
//   Future<List<Friend>> getAllFriends() async {
//     final db = await dbHelper.database;
//     final List<Map<String, dynamic>> result = await db.query('Friends');
//     return result.map((map) => Friend(
//       userId: map['user_id'],
//       friendId: map['friend_id'],
//     )).toList();
//   }
//
//   Future<int> deleteFriend(int userId, int friendId) async {
//     final db = await dbHelper.database;
//     return await db.delete('Friends', where: 'user_id = ? AND friend_id = ?', whereArgs: [userId, friendId]);
//   }
// }