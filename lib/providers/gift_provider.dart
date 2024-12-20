// import 'package:flutter/material.dart';
//
// class GiftProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _gifts = [];
//
//   List<Map<String, dynamic>> get gifts => _gifts;
//
//   void addGift(Map<String, dynamic> gift) {
//     _gifts.add(gift);
//     notifyListeners();
//   }
//
//   void removeGift(String giftId) {
//     _gifts.removeWhere((gift) => gift['id'] == giftId);
//     notifyListeners();
//   }
//
//   void updateGift(String giftId, Map<String, dynamic> updatedGift) {
//     int index = _gifts.indexWhere((gift) => gift['id'] == giftId);
//     if (index != -1) {
//       _gifts[index] = updatedGift;
//       notifyListeners();
//     }
//   }
//
//   void pledgeGift(String giftId) {
//     int index = _gifts.indexWhere((gift) => gift['id'] == giftId);
//     if (index != -1) {
//       _gifts[index]['status'] = 'Pledged';
//       notifyListeners();
//     }
//   }
// }
