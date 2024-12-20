import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/notfi_service.dart';

import 'gift_details_page.dart';

class EventGiftsPage extends StatelessWidget {
  final String eventId;
  final String friendId;
  final String eventName;
  final String eventCategory;

  const EventGiftsPage({
    Key? key,
    required this.eventId,
    required this.friendId,
    required this.eventName,
    required this.eventCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gifts for Event'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('events')
            .doc(eventId)
            .collection('gifts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No gifts available.'));
          }

          final gifts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              final isPledged = gift['pledgedBy'] != null;
              final isPledgedByCurrentUser = gift['pledgedBy'] == currentUserId;

              return FutureBuilder<DocumentSnapshot>(
                future: isPledged
                    ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(gift['pledgedBy'])
                    .get()
                    : null,
                builder: (context, userSnapshot) {
                  final pledgedByUsername = userSnapshot.hasData
                      ? userSnapshot.data!['fullName'] ?? 'Unknown User'
                      : null;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        gift['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        isPledged
                            ? 'Pledged by: $pledgedByUsername'
                            : 'Details: ${gift['details'] ?? 'No details'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      leading: const Icon(
                        Icons.card_giftcard,
                        color: Colors.brown,
                      ),
                      trailing: isPledged
                          ? isPledgedByCurrentUser
                          ? ElevatedButton(
                        onPressed: () => _undoPledgeGift(context, gift.id),
                        child: const Text('Undo Pledge'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      )
                          : const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                        onPressed: () => _confirmPledgeGift(context, gift, currentUserId!),
                        child: const Text('Pledge'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftDetailsPage(gift: gift),
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

  void _confirmPledgeGift(BuildContext context, QueryDocumentSnapshot gift, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Pledge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event: $eventName'),
              Text('Category: $eventCategory'),
              const SizedBox(height: 8),
              Text('Gift: ${gift['name']}'),
              Text('Details: ${gift['details'] ?? 'No details'}'),
              Text('Price: \$${gift['price'].toString()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendId)
                    .collection('events')
                    .doc(eventId)
                    .collection('gifts')
                    .doc(gift.id)
                    .update({
                  'pledgedBy': userId,
                });

                Navigator.pop(context);

                NotificationService().showNotification(title: 'Pledge Confirmed', body: 'You have pledged to gift "${gift['name']}" for $eventName.');

              },
              child: const Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _undoPledgeGift(BuildContext context, String giftId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .doc(giftId)
        .update({
      'pledgedBy': null,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pledge undone successfully.')),
    );
  }
}