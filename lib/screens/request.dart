import 'package:chat/models/account.dart';
import 'package:chat/screens/home.dart';
import 'package:chat/screens/messagesScreen.dart';
import 'package:chat/screens/notification.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.account});
  final Account account;

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _selectedIndex = 2; // Default tab index

  // Stream that listens to requests related to the user
  Stream<List<Map<String, dynamic>>> fetchLawyerRequests() {
    return _firestore
        .collection('requests')
        .where('userId', isEqualTo: widget.account.uid) // Filter requests
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Handles bottom navigation
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

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

      default:
        return;
    }

    Get.offAll(() => nextScreen, transition: Transition.noTransition);
  }

  // Extracts and formats the request date safely
  String getFormattedDate(Map<String, dynamic> request) {
    Timestamp? timestamp;

    if (request['date'] != null) {
      final dynamic dateValue = request['date'];

      if (dateValue is Timestamp) {
        timestamp = dateValue; // Correct Firestore Timestamp
      } else if (dateValue is String) {
        try {
          timestamp = Timestamp.fromDate(DateTime.parse(dateValue));
        } catch (e) {
          debugPrint("Error parsing date string: $e");
          timestamp = null;
        }
      } else {
        debugPrint("Unexpected date format: $dateValue");
      }
    }

    if (timestamp != null) {
      DateTime dateTime = timestamp.toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }

    return "Unknown Date";
  }

  // Creates a request card widget
  Widget getRequestCard(Map<String, dynamic> request) {
    final String title = request['title'] ?? 'Unknown Title';
    final String lawyerName = request['lawyerName'] ?? 'Unknown Lawyer';
    final String status = request['status'] ?? 'Unknown Status';
    final String formattedDate = getFormattedDate(request);
    final String receiverEmail = request['lawyerEmail'] ?? '';
    final String receiverID = request['lawyerId'] ?? '';
    //  final String fees = request['fees'] ?? '0.0';

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lawyer: $lawyerName"),
            Text("Date: $formattedDate"),
            Text(
              "Status: $status",
              style: TextStyle(
                color: status == 'Pending'
                    ? Colors.amber
                    : status == 'Accepted'
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            //  Text("$fees")
          ],
        ),
        trailing: status == 'Accepted'
            ? GestureDetector(
                child: SizedBox(
                  width: 90, // Prevent overflow
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text('Go to chats', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
                onTap: () {
                  Get.to(() => MessagesScreen(account: widget.account),
                      transition: Transition.noTransition);
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        toolbarHeight: 70,
        title: Text("Requests",
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 40,
                color: Color.fromARGB(255, 72, 47, 0),
              ),
            )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF5EEDC),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchLawyerRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Error fetching requests"));
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No requests sent."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return getRequestCard(snapshot.data![index]);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 147, 96, 0),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.bell), label: "Notifications"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageCircle), label: "Chat"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
        ],
      ),
    );
  }
}
