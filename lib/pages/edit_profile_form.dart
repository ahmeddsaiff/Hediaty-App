import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileForm extends StatefulWidget {
  final VoidCallback onSave;

  const EditProfileForm({Key? key, required this.onSave}) : super(key: key);

  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = "";
  String _password = "";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _fullName = doc['fullName'] ?? "";
      });
    }
  }

  Future<void> _updateUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (_password.isNotEmpty) {
        await user.updatePassword(_password);
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fullName': _fullName});
      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _fullName,
            decoration: const InputDecoration(labelText: "Full Name"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your full name";
              }
              return null;
            },
            onSaved: (value) {
              _fullName = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Password"),
            validator: (value) {
              if (value != null && value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                _updateUserDetails();
              }
            },
            child: const Text("Save"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
