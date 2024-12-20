import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pledged_gifts_page.dart';
import 'edit_profile_form.dart';
import 'gift_list_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _fullName = "";
  List<DocumentSnapshot> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchEvents();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _fullName = doc['fullName'] ?? "User Name";
      });
    }
  }

  Future<void> _fetchEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .get();

      setState(() {
        _events = querySnapshot.docs;
      });
    }
  }

  Future<void> _deleteAllEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _events.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All events deleted successfully!")),
      );
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: EditProfileForm(
              onSave: () {
                _fetchUserDetails();
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.brown.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/img_1.png'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 12),
            Text(
              _fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPledgedGiftsPage()),
                );
              },
              child: const Text("My Pledged Gifts"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _deleteAllEvents,
              child: const Text("Delete All Events"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showEditProfileDialog,
              child: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Events",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _events.isEmpty
                  ? const Center(child: Text("No events found."))
                  : ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        event['name'] ?? "Unnamed Event",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Category: ${event['category'] ?? 'N/A'}\nStatus: ${event['status'] ?? 'N/A'}",
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
                            builder: (context) => GiftListPage(eventId: event.id, eventName: event['name']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


