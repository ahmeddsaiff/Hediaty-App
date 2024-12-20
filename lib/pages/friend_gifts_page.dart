import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_gifts_page.dart';

class FriendGiftPage extends StatelessWidget {
  final String phone;

  const FriendGiftPage({Key? key, required this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events List"),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getFriendIdByPhone(phone),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Friend not found.'));
          }

          final friendData = snapshot.data!;
          final friendId = friendData.id;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(friendId)
                .collection('events')
                .where('status', isNotEqualTo: 'Past')
                .snapshots(),
            builder: (context, eventSnapshot) {
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!eventSnapshot.hasData || eventSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No events available.'));
              }

              final events = eventSnapshot.data!.docs;

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        event['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Category: ${event['category']}\nStatus: ${event['status']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      leading: const Icon(
                        Icons.event,
                        color: Colors.brown,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventGiftsPage(
                              eventId: event.id,
                              friendId: friendId,
                              eventName: event['name'],
                              eventCategory: event['category'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> _getFriendIdByPhone(String phone) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return Future.value(null);
    }

    return snapshot.docs.first;
  }
}