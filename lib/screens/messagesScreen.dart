import 'package:chat/models/account.dart';
import 'package:chat/screens/chat.dart';
import 'package:chat/screens/home.dart';
import 'package:chat/screens/notification.dart';
import 'package:chat/screens/request.dart';
import 'package:chat/screens/wallet.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/widgets/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final AuthService authService = AuthService();
  int selectedIndex = 2; // Persistent state for bottom nav selection

  // Handles bottom navigation
  void onItemTapped(int index) {
    if (selectedIndex == index) return; // Prevent unnecessary rebuilds
    setState(() => selectedIndex = index);

    switch (index) {
      case 0:
        Get.off(() => NotificationsScreen(account: widget.account),
            transition: Transition.noTransition);
        break;
      case 1:
        Get.off(() => WalletScreen(account: widget.account),
            transition: Transition.noTransition);
        break;
      case 3:
        Get.off(() => RequestsScreen(account: widget.account),
            transition: Transition.noTransition);
        break;
      case 4:
        Get.off(() => HomeScreen(account: widget.account),
            transition: Transition.noTransition);
        break;
    }
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
        backgroundColor: Color(0xFFF5EEDC), // Purple color
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
          icon: Icon(LucideIcons.wallet),
          label: "Wallet",
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
      stream: chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text('Error loading users',
                  style: TextStyle(color: Colors.red, fontSize: 18)));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(); // Custom empty state widget
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

  // User list item widget
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != authService.getCurrentUser()!.email) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            title: Text(userData["email"] ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text("Tap to chat", style: TextStyle(color: Colors.grey[600])),
            leading: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 136, 97, 0),
              child: Text(
                userData["email"]?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            // trailing: Icon(
            //   Icons.chat_bubble,
            //   color: Color(0xFFF5EEDC),
            // ),
            onTap: () {
              Get.to(() => ChatScreen(
                    receiverEmail: userData["email"] ?? 'email',
                    receiverID: userData["uid"] ?? 'uid',
                  ));
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
