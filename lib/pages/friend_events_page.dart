import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendEventsPage extends StatefulWidget {
  final String phone;

  const FriendEventsPage({Key? key, required this.phone}) : super(key: key);

  @override
  _FriendEventsPageState createState() => _FriendEventsPageState();
}

class _FriendEventsPageState extends State<FriendEventsPage> {
  String _sortBy = 'name'; // Default sorting by name
  bool _ascending = true; // Default sorting order

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend's Events"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == _sortBy) {
                  _ascending = !_ascending; // Toggle sorting order
                } else {
                  _sortBy = value;
                  _ascending = true; // Reset to ascending order
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'status', child: Text('Sort by Status')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getFriendIdByPhone(widget.phone),
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
            stream: _fetchFriendEvents(friendId),
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
                  return ListTile(
                    title: Text(event['name']),
                    subtitle: Text('Category: ${event['category']}\nStatus: ${event['status']}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _fetchFriendEvents(String friendId) {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .collection('events')
        .orderBy(_sortBy, descending: !_ascending);

    return query.snapshots();
  }

  Future<DocumentSnapshot> _getFriendIdByPhone(String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid; // Get the logged-in user's UID

    if (userId == null) {
      // Handle case where user is not logged in
      return Future.value(null);
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return Future.value(null); // Return null if no friend is found
    }

    return snapshot.docs.first;
  }
}