// import 'package:flutter/material.dart';
//
// class EventProvider with ChangeNotifier {
//   List<Map<String, String>> _events = [];
//
//   List<Map<String, String>> get events => _events;
//
//   void addEvent(Map<String, String> event) {
//     _events.add(event);
//     notifyListeners();
//   }
//
//   void removeEvent(String eventId) {
//     _events.removeWhere((event) => event['id'] == eventId);
//     notifyListeners();
//   }
//
//   void updateEvent(String eventId, Map<String, String> newEventDetails) {
//     int index = _events.indexWhere((event) => event['id'] == eventId);
//     if (index != -1) {
//       _events[index] = newEventDetails;
//       notifyListeners();
//     }
//   }
// }
