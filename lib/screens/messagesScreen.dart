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
  List<String> chatRooms = [];
  int selectedIndex = 1; // Persistent state for bottom nav selection
  @override
  void initState() {
    super.initState();
    authService = AuthService();
    currentUser = authService.getCurrentUser();

    if (currentUser != null) {
      // Wrap the Firestore call in Future.delayed
      Future.delayed(Duration.zero, () => fetchChatRoomIds());
    } else {
      print("No logged-in user.");
    }
  }

  void fetchChatRoomIds() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('chat_rooms').get();

      List<String> roomIds = snapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        chatRooms = roomIds; // Updating state with only IDs
      });

      debugPrint("Chat Room IDs: $roomIds"); // Print the IDs for debugging
    } catch (e) {
      debugPrint("Error fetching chat room IDs: $e");
    }
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        toolbarHeight: 80,
        title: Text("Messages",
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFF5EEDC),
      ),
      body: _buildUserList(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: Colors.white,
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
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.clipboardList),
          label: "Requests",
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: "Home",
        ),
      ],
    );
  }

  // User list stream
  Widget _buildUserList() {
    return StreamBuilder(
      stream: chatService.getLawyerStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text('Error loading users',
                  style: TextStyle(color: Colors.red, fontSize: 18)));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        return ListView(
          children: snapshot.data!
                  .map<Widget>(
                      (userData) => _buildUserListItem(userData, context))
                  .toList() ??
              [],
        );
      },
    );
  }

  // Empty state widget when no users are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey),
          SizedBox(height: 20),
          Text("No messages available",
              style: TextStyle(fontSize: 20, color: Colors.grey)),
        ],
      ),
    );
  }

  bool userHasChatRoom() {
    return chatRooms.any((roomId) {
      List<String> participants = roomId.split("_");
      return participants.contains(currentUser!.uid);
    });
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Get user's chat rooms
    bool hasChat = chatRooms.any((roomId) {
      List<String> participants = roomId.split("_");
      return participants.contains(currentUser!.uid);
    });

    if (hasChat) {
      return Container(
        child: Text(
          "No chat rooms found for user",
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          title: Text(userData["name"] ?? 'Unknown User',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle:
              Text("Tap to chat", style: TextStyle(color: Colors.grey[600])),
          leading: CircleAvatar(
            backgroundColor: Color.fromARGB(255, 136, 97, 0),
            child: userData["pic"] ??
                Text(
                  userData["name"]?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
          ),
          onTap: () {
            Get.to(() => ChatScreen(
                  receiverID: userData["uid"] ?? '',
                ));
          },
        ),
      ),
    );
  }
}
