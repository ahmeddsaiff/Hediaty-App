import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friend_events_page.dart';
import 'friend_gifts_page.dart';

class FriendDetailsPage extends StatelessWidget {
  final String phone; // We will search by phone number

  const FriendDetailsPage({Key? key, required this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Details"),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _searchFriendByPhone(phone),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Friend data not found."));
          }

          final friendData = snapshot.data!.first;
          final data = friendData.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    "Full Name: ${data['name'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Phone: ${data['phone'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  leading: const Icon(
                    Icons.person,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendGiftPage(phone: phone),
                      ),
                    );
                  },
                  child: const Text("View Required Gifts"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendEventsPage(phone: phone),
                      ),
                    );
                  },
                  child: const Text("View Events Attending"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _searchFriendByPhone(String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid; // Get the logged-in user's UID

    if (userId == null) {
      // Handle case where user is not logged in
      return [];
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('friends')
        .where('phone', isEqualTo: phone)
        .get();

    return snapshot.docs;
  }
}