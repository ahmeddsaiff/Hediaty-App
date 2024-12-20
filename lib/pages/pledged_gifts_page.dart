import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gift_details_page.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<Map<String, dynamic>> _pledgedGifts = [];

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collectionGroup('gifts')
            .where('pledgedBy', isEqualTo: user.uid)
            .get();

        List<Map<String, dynamic>> gifts = [];

        if (querySnapshot.docs.isEmpty) {
          print("No pledged gifts found for the current user.");
        }

        for (var doc in querySnapshot.docs) {
          final eventRef = doc.reference.parent.parent;
          if (eventRef != null) {
            final eventDoc = await eventRef.get();
            final creatorDoc = await eventRef.parent.parent!.get();

            if (eventDoc.exists && creatorDoc != null && creatorDoc.exists) {
              gifts.add({
                'giftId': doc.id,
                'eventName': eventDoc.data()?['name'] ?? 'Unknown Event',
                'creatorName': creatorDoc.data()?['fullName'] ?? 'Unknown Creator',
                'giftName': doc.data()?['name'] ?? 'Unnamed Gift',
                'eventId': eventDoc.id,
                'price': doc.data()?['price'] ?? 'N/A',
                'giftDoc': doc, // Add the document snapshot for navigation
              });
            } else {
              print("Event or Creator document does not exist for gift: ${doc.id}");
            }
          } else {
            print("Parent event reference not found for gift: ${doc.id}");
          }
        }

        setState(() {
          _pledgedGifts = gifts;
        });

        print("Fetched pledged gifts: $_pledgedGifts");
      } catch (e) {
        print("Error fetching pledged gifts: $e");
      }
    } else {
      print("No user is logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pledged Gifts"),
        backgroundColor: Colors.brown.shade700,
      ),
      body: _pledgedGifts.isEmpty
          ? const Center(child: Text("No pledged gifts found."))
          : ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = _pledgedGifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => GiftDetailsPage(gift: gift['giftDoc']),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: ListTile(
                title: Text(
                  gift['giftName'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Event: ${gift['eventName']}"),
                    Text("Creator: ${gift['creatorName']}"),
                    Text("Price: \$${gift['price']}"),
                  ],
                ),
                leading: const Icon(
                  Icons.card_giftcard,
                  color: Colors.brown,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}