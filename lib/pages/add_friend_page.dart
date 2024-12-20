import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Reference to Firestore
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: const Text("Add Friend"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Friend's Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Friend's Name",
                labelStyle: TextStyle(color: Colors.brown.shade600),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Phone Number Input
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: TextStyle(color: Colors.brown.shade600),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
                ),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            // Add Friend Button
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                  String phoneNumber = _phoneController.text.trim();  // Trim the input
                  final userId = FirebaseAuth.instance.currentUser?.uid;

                  if (userId != null) {
                    bool friendExists = false;

                    // Check if the phone number already exists in the user's friends list
                    await usersCollection
                        .doc(userId)
                        .collection('friends')
                        .where('phone', isEqualTo: phoneNumber)
                        .get()
                        .then((querySnapshot) {
                      if (querySnapshot.docs.isNotEmpty) {
                        friendExists = true;
                      }
                    });

                    if (friendExists) {
                      // Show a SnackBar if the friend already exists
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This friend is already in your list')),
                      );
                    } else {
                      // Query all documents and check if any contains the phone number
                      bool userExists = false;
                      await usersCollection.get().then((querySnapshot) {
                        for (var doc in querySnapshot.docs) {
                          var phoneField = doc.data() as Map<String, dynamic>;
                          if (phoneField.containsKey('phone') && phoneField['phone'] == phoneNumber) {
                            userExists = true;
                            break;
                          }
                        }
                      });

                      if (userExists) {
                        // If the user exists, add them to the friends list in HomePage
                        Navigator.pop(context, {
                          'name': _nameController.text,
                          'phone': phoneNumber,
                        });
                      } else {
                        // Show a SnackBar if no account exists for this phone number
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No account found for this phone number')),
                        );
                      }
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text("Add Friend"),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.brown.shade700),
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16)),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}