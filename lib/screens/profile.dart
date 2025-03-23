import 'package:chat/models/account.dart';
import 'package:chat/screens/home.dart';
import 'package:chat/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  final Account account;

  const ProfileScreen({super.key, required this.account});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseFirestore fyre = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getInfo() async {
    try {
      var querySnapshot = await fyre
          .collection('account')
          .where('email', isEqualTo: widget.account.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null; // Return null if no document is found
    } catch (e) {
      print("Error fetching profile data: $e");
      return null;
    }
  }

  Future<void> updateInfo() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.off(HomeScreen(account: widget.account));
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Profile"),
        backgroundColor: Color(0xFFF5EEDC),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: getInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return Center(child: Text("Error loading profile data."));
          }

          var userData = snapshot.data!.data() ?? {};

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      userData['photoURL'] ?? 'assets/images/brad.webp',
                    ),
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 20),

                  // User Name
                  Text(
                    userData['name'] ?? "No Name",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // User Email
                  Text(
                    userData['email'] ?? "No Email",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 30),

                  // User Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            trailing: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                            leading: Icon(Icons.phone, color: Colors.black),
                            title: Text("Phone Number"),
                            subtitle: Text(
                              userData['number'] ?? "Not provided",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading:
                                Icon(Icons.calendar_today, color: Colors.black),
                            title: Text("Joined Date"),
                            subtitle: Text(
                              userData['joinedDate'] ?? "Unknown",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.off(LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
