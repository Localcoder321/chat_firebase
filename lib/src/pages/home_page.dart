import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/src/services/auth/auth_service.dart';
import 'package:flutter/material.dart';


import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
    final authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home page"),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: _buildUserList(),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        final userList = snapshot.data!.docs.map((doc) => _buildUserListItem(doc)).toList();
        return ListView(
          children: userList,
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    if (_auth.currentUser?.email != data["email"]) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
          tileColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            data["email"],
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: data["email"],
                  receiverUserID: data["uid"],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(); // Exclude the current user from the list.
    }
  }
}

