import 'package:chat/models/account.dart';
import 'package:chat/screens/chat.dart';
import 'package:chat/screens/home.dart';
import 'package:chat/screens/notification.dart';
import 'package:chat/screens/request.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.account});
  final Account account;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatService chatService = ChatService();
  late AuthService authService;
  User? currentUser;

  int selectedIndex = 1; // Persistent state for bottom nav selection
  @override
  void initState() {
    super.initState();
    authService = AuthService();
    currentUser = authService.getCurrentUser();
  }

  // Handles bottom navigation
  void onItemTapped(int index) {
    if (index == selectedIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = NotificationsScreen(account: widget.account);
        break;
      case 1:
        nextScreen = MessagesScreen(account: widget.account);
        break;
      case 2:
        nextScreen = RequestsScreen(account: widget.account);
        break;
      case 3:
        nextScreen = HomeScreen(account: widget.account);
        break;
      default:
        return;
    }

    Get.offAll(() => nextScreen, transition: Transition.noTransition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        toolbarHeight: 40,
        title: Text("Messages",
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 255, 255), // Purple color
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: const Color.fromARGB(255, 0, 0, 0)),
            onPressed: () {}, // Implement search functionality here
          ),
        ],
      ),
      body: _buildUserList(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Bottom Navigation Bar styling
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      selectedItemColor: const Color.fromARGB(255, 147, 96, 0),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.bell),
          label: "Notifications",
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.messageCircle),
          label: "Wallet",
        ),
        BottomNavigationBarItem(
            icon: Icon(LucideIcons.clipboardList), label: ""),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: "Home",
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> fetchACCRequests() async {
    var _firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await _firestore
        .collection('requests')
        .where('userId', isEqualTo: widget.account.uid)
        .where('status', isEqualTo: "Accepted")
        .get();

    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  // User list stream
  Widget _buildUserList() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchACCRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching requests'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No requests yet.'));
          }

          List<Map<String, dynamic>> requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              var _firestore = FirebaseFirestore.instance;
              return FutureBuilder<DocumentSnapshot>(
                  future: _firestore
                      .collection('account')
                      .doc(request['lawyerId'])
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile();
                    } else if (userSnapshot.hasError ||
                        !userSnapshot.hasData ||
                        !userSnapshot.data!.exists) {
                      return ListTile();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          title: Text(request["lawyerName"] ?? 'Unknown User',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Tap to chat",
                              style: TextStyle(color: Colors.grey[600])),
                          leading: CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 136, 97, 0),
                            child: request["pic"] ??
                                Text(
                                  request["lawyerName"]
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'U',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                          ),
                          onTap: () {
                            Get.to(
                                transition: Transition.rightToLeft,
                                () => Chat(
                                      receivername: request['lawyerName'] ?? '',
                                      senderId: request["userId"] ?? '',
                                      receiverID: request["lawyerId"] ?? '',
                                      rid: request['rid'] ?? '',
                                    ));
                          },
                        ),
                      ),
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
