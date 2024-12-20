// import 'database_helper.dart';
//
// class EventRepo {
//   final int? id;
//   final String name;
//   final String category;
//   final String status;
//   final String location;
//   final String description;
//   final String userId;
//
//   EventRepo({
//     this.id,
//     required this.name,
//     required this.category,
//     required this.status,
//     required this.location,
//     required this.description,
//     required this.userId,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'category': category,
//       'status': status,
//       'location': location,
//       'description': description,
//       'userId': userId,
//     };
//   }
// }
//
// class EventRepository {
//   final dbHelper = DatabaseHelper();
//
//   Future<int> insertEvent(EventRepo event) async {
//     try {
//       final db = await dbHelper.database;
//       return await db.insert('Events', event.toMap());
//     } catch (e) {
//       throw Exception('Failed to insert event: $e');
//     }
//   }
//
//   Future<List<EventRepo>> getAllEvents(String userId) async {
//     try {
//       final db = await dbHelper.database;
//       final List<Map<String, dynamic>> result = await db.query('Events', where: 'userId = ?', whereArgs: [userId]);
//       return result.map((map) => EventRepo(
//         id: map['id'],
//         name: map['name'],
//         category: map['category'],
//         status: map['status'],
//         location: map['location'],
//         description: map['description'],
//         userId: map['userId'],
//       )).toList();
//     } catch (e) {
//       throw Exception('Failed to get events: $e');
//     }
//   }
//
//   Future<int> updateEvent(EventRepo event) async {
//     try {
//       final db = await dbHelper.database;
//       return await db.update('Events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
//     } catch (e) {
//       throw Exception('Failed to update event: $e');
//     }
//   }
//
//   Future<int> deleteEvent(int id) async {
//     try {
//       final db = await dbHelper.database;
//       return await db.delete('Events', where: 'id = ?', whereArgs: [id]);
//     } catch (e) {
//       throw Exception('Failed to delete event: $e');
//     }
//   }
// }