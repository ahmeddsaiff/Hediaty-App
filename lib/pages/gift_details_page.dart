import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GiftDetailsPage extends StatelessWidget {
  final DocumentSnapshot gift;

  const GiftDetailsPage({Key? key, required this.gift}) : super(key: key);

  Future<String> _getFullNameFromId(String userId) async {
    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['fullName'] ?? 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: Text(
          gift['name'] ?? 'Gift Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${gift['name'] ?? 'Unnamed Gift'}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown.shade700),
            ),
            SizedBox(height: 10),
            Text(
              'Price: \$${gift['price'] ?? 0}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown.shade600),
            ),
            SizedBox(height: 10),
            Text(
              'Details: ${gift['details'] ?? 'No details available'}',
              style: TextStyle(fontSize: 18, color: Colors.brown.shade500),
            ),
            SizedBox(height: 20),
            if (gift['imageUrl'] != null && gift['imageUrl'].isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    gift['imageUrl'],
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            SizedBox(height: 20),
            if (gift['pledgedBy'] != null)
              FutureBuilder<String>(
                future: _getFullNameFromId(gift['pledgedBy']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Loading...', style: TextStyle(fontSize: 16)),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Error fetching full name',
                          style: TextStyle(fontSize: 16, color: Colors.red)),
                    );
                  } else if (snapshot.hasData) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Text(
                        'Pledged by: ${snapshot.data}',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Text(
                        'Pledged by: Unknown',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}