import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gift_list_page.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String _sortBy = 'name'; // Default sorting by name
  bool _ascending = true; // Default sorting order
  String _filterStatus = 'All'; // Default filter status

  final Color primaryColor = Colors.brown.shade700;
  final Color accentColor = Color(0xFFFFF4E5);  // Light beige

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
        backgroundColor: primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: 'Sort Events',
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
              const PopupMenuItem(value: 'category', child: Text('Sort by Category')),
              const PopupMenuItem(value: 'status', child: Text('Sort by Status')),
            ],
          ),
          DropdownButton<String>(
            value: _filterStatus,
            dropdownColor: primaryColor.withOpacity(0.9),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            underline: Container(height: 0),
            onChanged: (value) {
              setState(() {
                _filterStatus = value!;
              });
            },
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
              DropdownMenuItem(value: 'Current', child: Text('Current')),
              DropdownMenuItem(value: 'Past', child: Text('Past')),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[100], // Slightly lighter background for a fresher look
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchUserEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No events added yet.\nTap the "+" button to create your first event!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            key: ValueKey(events.length),
            padding: const EdgeInsets.all(8.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                elevation: 8, // Enhanced elevation for a more prominent card
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    event['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      'Category: ${event['category']}\n'
                          'Location: ${event['location']}\n'
                          'Description: ${event['description']}\n'
                          'Status: ${event['status']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GiftListPage(eventId: event.id, eventName: event['name']),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit Event',
                        icon: Icon(Icons.edit, color: primaryColor),
                        onPressed: () => _editEvent(event),
                      ),
                      IconButton(
                        tooltip: 'Delete Event',
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteEvent(event.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _addEvent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Stream<QuerySnapshot> _fetchUserEvents() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.empty();
    }

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .orderBy(_sortBy, descending: !_ascending);

    if (_filterStatus != 'All') {
      query = query.where('status', isEqualTo: _filterStatus);
    }

    return query.snapshots();
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final categoryController = TextEditingController();
        final locationController = TextEditingController();
        final descriptionController = TextEditingController();
        String status = 'Upcoming';

        return AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField('Event Name', nameController),
                _buildDialogTextField('Category', categoryController),
                _buildDialogTextField('Location', locationController),
                _buildDialogTextField('Description', descriptionController),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'Current', child: Text('Current')),
                    DropdownMenuItem(value: 'Past', child: Text('Past')),
                  ],
                  onChanged: (value) {
                    status = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              onPressed: () async {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('events')
                      .add({
                    'name': nameController.text,
                    'category': categoryController.text,
                    'location': locationController.text,
                    'description': descriptionController.text,
                    'status': status,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editEvent(QueryDocumentSnapshot event) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: event['name']);
        final categoryController = TextEditingController(text: event['category']);
        final locationController = TextEditingController(text: event['location']);
        final descriptionController = TextEditingController(text: event['description']);
        String status = event['status'];

        return AlertDialog(
          title: const Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField('Event Name', nameController),
                _buildDialogTextField('Category', categoryController),
                _buildDialogTextField('Location', locationController),
                _buildDialogTextField('Description', descriptionController),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'Current', child: Text('Current')),
                    DropdownMenuItem(value: 'Past', child: Text('Past')),
                  ],
                  onChanged: (value) {
                    status = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              onPressed: () async {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('events')
                      .doc(event.id)
                      .update({
                    'name': nameController.text,
                    'category': categoryController.text,
                    'location': locationController.text,
                    'description': descriptionController.text,
                    'status': status,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  void _deleteEvent(String eventId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event Deleted Successfully'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
