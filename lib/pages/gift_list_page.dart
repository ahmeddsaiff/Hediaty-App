import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;
  final String eventName;

  const GiftListPage({Key? key, required this.eventId, required this.eventName})
      : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<DocumentSnapshot> _gifts = [];
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  String _sortBy = 'name'; // Default sorting by name
  bool _ascending = true; // Default sorting order
  String _filterByPledged = 'All'; // Default filter by all gifts

  @override
  void initState() {
    super.initState();
    _fetchGifts();
  }

  Future<void> _fetchGifts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts');

      if (_filterByPledged == 'Pledged') {
        query = query.where('pledgedBy', isNotEqualTo: null);
      } else if (_filterByPledged == 'Unpledged') {
        query = query.where('pledgedBy', isEqualTo: null);
      }

      // Add sorting logic
      query = query.orderBy(_sortBy, descending: !_ascending);

      final querySnapshot = await query.get();

      setState(() {
        _gifts = querySnapshot.docs;
      });
    }
  }

  Future<String> _getPledgerName(String userId) async {
    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['fullName'] ?? 'Unknown User';
  }

  void _addGift() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final giftNameController = TextEditingController();
      final giftPriceController = TextEditingController();
      final giftDetailsController = TextEditingController();
      final giftImageUrlController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Add New Gift"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: giftNameController,
                decoration: InputDecoration(labelText: "Gift Name"),
              ),
              TextField(
                controller: giftPriceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: giftDetailsController,
                decoration: InputDecoration(labelText: "Details"),
              ),
              TextField(
                controller: giftImageUrlController,
                decoration: InputDecoration(labelText: "Image URL (optional)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (giftNameController.text.isNotEmpty &&
                    giftPriceController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('events')
                      .doc(widget.eventId)
                      .collection('gifts')
                      .add({
                    'name': giftNameController.text,
                    'price': double.tryParse(giftPriceController.text),
                    'details': giftDetailsController.text.isEmpty
                        ? null
                        : giftDetailsController.text,
                    'imageUrl': giftImageUrlController.text.isEmpty
                        ? null
                        : giftImageUrlController.text,
                    'pledgedBy': null,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gift added successfully!")),
                  );
                  _fetchGifts(); // Refresh the list
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
      );
    }
  }

  void _editGift(DocumentSnapshot gift) async {
    if (gift['pledgedBy'] != null && gift['pledgedBy'].isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot edit, gift is pledged.')),
      );
      return; // Cannot edit if pledged
    }

    final giftNameController = TextEditingController(text: gift['name']);
    final giftPriceController = TextEditingController(
        text: (gift['price'] ?? 0).toString());
    final giftDetailsController = TextEditingController(text: gift['details']);
    final giftImageUrlController = TextEditingController(text: gift['imageUrl']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Gift"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: giftNameController,
              decoration: InputDecoration(labelText: "Gift Name"),
            ),
            TextField(
              controller: giftPriceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: giftDetailsController,
              decoration: InputDecoration(labelText: "Details"),
            ),
            TextField(
              controller: giftImageUrlController,
              decoration: InputDecoration(labelText: "Image URL (optional)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('events')
                  .doc(widget.eventId)
                  .collection('gifts')
                  .doc(gift.id)
                  .update({
                'name': giftNameController.text,
                'price': double.tryParse(giftPriceController.text),
                'details': giftDetailsController.text.isEmpty
                    ? null
                    : giftDetailsController.text,
                'imageUrl': giftImageUrlController.text.isEmpty
                    ? null
                    : giftImageUrlController.text,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Gift updated successfully!")),
              );
              _fetchGifts(); // Refresh the list
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteGift(String giftId) async {
    DocumentSnapshot giftSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('events')
        .doc(widget.eventId)
        .collection('gifts')
        .doc(giftId)
        .get();

    if (giftSnapshot.exists) {
      final pledgedBy = giftSnapshot['pledgedBy'] as String?;

      if (pledgedBy != null && pledgedBy.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot delete, gift is pledged by $pledgedBy.')),
        );
        return; // Abort deletion
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(giftId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift deleted successfully!')),
      );
      _fetchGifts(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Gifts for ${widget.eventName}', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              if (value == 'price') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Sort by Price'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Ascending'),
                          onTap: () {
                            setState(() {
                              _sortBy = 'price';
                              _ascending = true;
                              _fetchGifts();
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text('Descending'),
                          onTap: () {
                            setState(() {
                              _sortBy = 'price';
                              _ascending = false;
                              _fetchGifts();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                setState(() {
                  if (value == _sortBy) {
                    _ascending = !_ascending; // Toggle sorting order
                  } else {
                    _sortBy = value;
                    _ascending = true; // Reset to ascending order
                  }
                  _fetchGifts(); // Refresh the list
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'price', child: Text('Sort by Price')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _addGift,
          ),
        ],
      ),
      body: _gifts.isEmpty
          ? const Center(child: Text("No gifts available."))
          : ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          final pledgedBy = gift['pledgedBy'] as String?;

          return FutureBuilder<String>(
            future: pledgedBy != null ? _getPledgerName(pledgedBy) : null,
            builder: (context, snapshot) {
              final pledgerName = snapshot.data;

              return Card(
                color: pledgedBy != null && pledgedBy.isNotEmpty
                    ? Colors.deepOrangeAccent[100]
                    : Colors.green[100],
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(gift['name'] ?? "Unnamed Gift"),
                  subtitle: Text(
                    pledgedBy != null
                        ? "Pledged by: $pledgerName"
                        : "Available for pledge",
                    style: TextStyle(color: Colors.black54),
                  ),
                  onTap: () {
                    // Navigate to the gift details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftDetailsPage(gift: gift),
                      ),
                    );
                  },
                  trailing: pledgedBy == null || pledgedBy.isEmpty
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editGift(gift),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGift(gift.id),
                      ),
                    ],
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.brown.shade700,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter by:', style: TextStyle(color: Colors.white)),
              DropdownButton<String>(
                value: _filterByPledged,
                onChanged: (value) {
                  setState(() {
                    _filterByPledged = value!;
                    _fetchGifts(); // Refresh the list
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Pledged', child: Text('Pledged')),
                  DropdownMenuItem(value: 'Unpledged', child: Text('Unpledged')),
                ],
                style: TextStyle(color: Colors.white),
                dropdownColor: Colors.brown.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}