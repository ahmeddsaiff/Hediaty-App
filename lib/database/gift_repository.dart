// import 'database_helper.dart';
//
// class Gift {
//   final int? id;
//   final String name;
//   final String details;
//   final String pledgedBy;
//   final double price;
//   final int eventId;
//
//   Gift({
//     this.id,
//     required this.name,
//     required this.details,
//     required this.pledgedBy,
//     required this.price,
//     required this.eventId,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'details': details,
//       'pledgedBy': pledgedBy,
//       'price': price,
//       'event_id': eventId,
//     };
//   }
// }
//
// class GiftRepository {
//   final dbHelper = DatabaseHelper();
//
//   Future<int> insertGift(Gift gift) async {
//     final db = await dbHelper.database;
//     return await db.insert('Gifts', gift.toMap());
//   }
//
//   Future<List<Gift>> getAllGifts() async {
//     final db = await dbHelper.database;
//     final List<Map<String, dynamic>> result = await db.query('Gifts');
//     return result.map((map) => Gift(
//       id: map['id'],
//       name: map['name'],
//       details: map['details'],
//       pledgedBy: map['pledgedBy'],
//       price: map['price'],
//       eventId: map['event_id'],
//     )).toList();
//   }
//
//   Future<List<Gift>> getGiftsByEventId(int eventId) async {
//     final db = await dbHelper.database;
//     final List<Map<String, dynamic>> result = await db.query('Gifts', where: 'event_id = ?', whereArgs: [eventId]);
//     return result.map((map) => Gift(
//       id: map['id'],
//       name: map['name'],
//       details: map['details'],
//       pledgedBy: map['pledgedBy'],
//       price: map['price'],
//       eventId: map['event_id'],
//     )).toList();
//   }
//
//   Future<int> updateGift(Gift gift) async {
//     final db = await dbHelper.database;
//     return await db.update('Gifts', gift.toMap(), where: 'id = ?', whereArgs: [gift.id]);
//   }
//
//   Future<int> deleteGift(int id) async {
//     final db = await dbHelper.database;
//     return await db.delete('Gifts', where: 'id = ?', whereArgs: [id]);
//   }
// }