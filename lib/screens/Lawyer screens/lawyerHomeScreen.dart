import 'package:chat/models/lawyer.dart';
import 'package:chat/screens/Lawyer%20screens/lawyerNotiScreen.dart';
import 'package:chat/screens/Lawyer%20screens/lawyerWalletScreen.dart';
import 'package:chat/screens/chat.dart';
import 'package:chat/screens/Lawyer screens/lawyerMessages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/lawsuitcard.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key, required this.lawyer});
  final Lawyer lawyer;

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var _selectedIndex = 3;

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('requests')
        .where('lawyerId', isEqualTo: widget.lawyer.uid)
        .get();

    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          drawer: Drawer(
            backgroundColor: Color(0xFFF5EEDC),
            child: Column(
              children: [],
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                ),
                SizedBox(width: 12),
                Text(
                  "Welcome, ${widget.lawyer.name ?? 'Lawyer'}",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 72, 47, 0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFFF5EEDC),
            foregroundColor: Colors.white,
            centerTitle: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text('Case Status',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                        label: 'Finished',
                        color: Colors.green,
                        icon: LucideIcons.checkCircle),
                    StatusBadge(
                        label: 'Waiting',
                        color: Colors.orange,
                        icon: LucideIcons.timer),
                    StatusBadge(
                        label: 'Active',
                        color: Colors.blue,
                        icon: LucideIcons.briefcase),
                  ],
                ),
                SizedBox(height: 20),
                Text('Consultation Requests',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchRequests(),
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

                          return FutureBuilder<DocumentSnapshot>(
                              future: _firestore
                                  .collection('account')
                                  .doc(request['userId'])
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

                                String username = userSnapshot.data!['name'] ??
                                    'Unknown User';

                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to ChatScreen when tapped
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          //   receiverEmail: userSnapshot.data!['email'] ?? 'unknown@email.com',
                                          receiverID: request['userId'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: LawsuitCard(
                                    status: request['status'],
                                    title: request['title'],
                                    rid: request['rid'],
                                  ),
                                );
                              });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color.fromARGB(255, 0, 0, 0),
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.bell),
                label: "Notifications",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.wallet),
                label: "Wallet",
              ),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.messageCircle), label: "Chat"),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.home), label: "Home"),
            ],
          ),
        ),
      ],
    );
  }

  void onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent unnecessary rebuilds
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Get.off(() => Lawyernotiscreen(lawyer: widget.lawyer),
            transition: Transition.noTransition);
        break;
      case 1:
        Get.off(() => lawyerWalletScreen(lawyer: widget.lawyer),
            transition: Transition.noTransition);
        break;

      case 2:
        Get.off(Lawyermessages(lawyer: widget.lawyer),
            transition: Transition.noTransition);
        break;
      case 3:
        Get.off(() => LawyerHomeScreen(lawyer: widget.lawyer),
            transition: Transition.noTransition);
        break;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const StatusBadge(
      {super.key,
      required this.label,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
