import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/Lawyer screens/lawSuitDetails.dart';

class LawsuitCard extends StatefulWidget {
  final String title;
  final String status;
  final String rid;
  final String username;
  final String type;
  final String date;
  final String time;
  const LawsuitCard({
    super.key,
    required this.title,
    required this.status,
    required this.rid,
    required this.username,
    required this.date,
    required this.time,
    required this.type,
  });

  @override
  State<LawsuitCard> createState() => _LawsuitCardState();
}

class _LawsuitCardState extends State<LawsuitCard> {
  FirebaseFirestore fyre = FirebaseFirestore.instance;
  String? requestId;
  String? status; // Local status state

  @override
  void initState() {
    super.initState();
    status = widget.status; // Initialize local status
    fetchRequestId();
  }

  /// Fetch the Firestore document ID for this request
  Future<void> fetchRequestId() async {
    try {
      print("Fetching requestId for rid: ${widget.rid}");

      var querySnapshot = await fyre
          .collection('requests')
          .where('rid', isEqualTo: widget.rid)
          .limit(1)
          .get();

      print("Query Result: ${querySnapshot.docs.length} documents found.");

      if (querySnapshot.docs.isNotEmpty) {
        requestId = querySnapshot.docs.first.id;
        print("Fetched requestId: $requestId");

        setState(() {}); // Update UI
      } else {
        print("No matching document found for rid: ${widget.rid}");
      }
    } catch (e) {
      print("Error fetching request: $e");
    }
  }

  /// Update request status in Firestore
  Future<void> updateRequestStatus(String newStatus) async {
    if (requestId == null) {
      print("Error: requestId is null. Cannot update status.");
      return;
    }

    try {
      await fyre
          .collection('requests')
          .doc(requestId)
          .update({'status': newStatus});

      if (mounted) {
        setState(() {
          status = newStatus;
        });
      }
    } catch (e) {
      print("Error updating Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Accepted'
        ? Colors.green
        : status == 'Pending'
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("Status: $status",
                      style: TextStyle(color: Colors.white)),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(
                        Lawsuit(
                          rid: widget.rid,
                        ),
                        transition: Transition.downToUp);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 14, 32, 41),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("View details",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage("https://i.imgur.com/QCNbOAo.png"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.username,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(widget.title, style: TextStyle(color: Colors.white)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white30),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Case type: ${widget.type}",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text("${widget.date.substring(0, 10)}",
                    style: TextStyle(color: Colors.white70)),
                SizedBox(width: 16),
                Icon(Icons.access_time, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text("${widget.time}", style: TextStyle(color: Colors.white70)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
