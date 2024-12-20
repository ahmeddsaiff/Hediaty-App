import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_friend_page.dart';
import 'event_list_page.dart';
import 'friend_details_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .get();

      List<Map<String, dynamic>> friends = [];
      for (var doc in snapshot.docs) {
        final friendData = {
          'id': doc.id,
          'name': doc['name'] as String,
          'phone': doc['phone'] as String,
        };
        friends.add(friendData);
      }

      setState(() {
        _friends = friends;
      });
    }
  }

  Future<int> _getUpcomingEventsCount(String friendPhone) async {
    final user = _auth.currentUser;
    if (user != null) {
      final friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: friendPhone)
          .limit(1)
          .get();

      if (friendSnapshot.docs.isEmpty) {
        return 0;
      }

      final friendId = friendSnapshot.docs.first.id;

      final eventSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('events')
          .where('status', isEqualTo: 'Upcoming')
          .get();

      return eventSnapshot.docs.length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E5),
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        title: const Text(
          "Hedieaty",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const EventPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      "My Events",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final newFriend = await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => AddFriendPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
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
                      if (newFriend != null) {
                        _addFriend(newFriend['name'], newFriend['phone']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      "Add Friend",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _friends.isEmpty
                  ? const Center(
                child: Text(
                  "No friends added yet.",
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 16.0,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => FriendDetailsPage(
                              phone: _friends[index]['phone']!,
                            ),
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
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('assets/img_3.png'),
                        ),
                        title: Text(
                          _friends[index]['name']!,
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: FutureBuilder<int>(
                          future: _getUpcomingEventsCount(_friends[index]['phone']!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text(
                                "Loading upcoming events...",
                                style: TextStyle(color: Colors.brown),
                              );
                            } else if (snapshot.hasError) {
                              return const Text(
                                "Error loading events",
                                style: TextStyle(color: Colors.red),
                              );
                            } else {
                              return Text(
                                "Upcoming Events: ${snapshot.data}",
                                style: TextStyle(color: Colors.brown.shade600),
                              );
                            }
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _deleteFriend(_friends[index]['id']!);
                          },
                        ),
                      ),
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

  Future<void> _addFriend(String name, String phone) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .add({'name': name, 'phone': phone});
      _loadFriends();
    }
  }

  Future<void> _deleteFriend(String friendId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friendId)
          .delete();
      _loadFriends();
    }
  }
}