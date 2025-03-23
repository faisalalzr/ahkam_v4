import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/Lawyer screens/lawSuitDetails.dart';

class LawsuitCard extends StatefulWidget {
  final String title;
  final String status;
  final String rid;

  const LawsuitCard({
    super.key,
    required this.title,
    required this.status,
    required this.rid,
  });

  @override
  State<LawsuitCard> createState() => _LawsuitCardState();
}

class _LawsuitCardState extends State<LawsuitCard> {
  FirebaseFirestore fyre = FirebaseFirestore.instance;
  String? requestId;
  String? status; // Local status state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    status = widget.status; // Initialize local status
    fetchRequestId();
  }

  /// Fetch the Firestore document ID for this request
  Future<void> fetchRequestId() async {
    try {
      var querySnapshot = await fyre
          .collection('requests')
          .where('rid', isEqualTo: widget.rid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          requestId = querySnapshot.docs.first.id;
        });
      }
    } catch (e) {
      print("Error fetching request: $e");
    }
  }

  /// Accepts the request and updates UI instantly
  Future<void> acceptRequest() async {
    if (requestId == null) return;

    await fyre
        .collection('requests')
        .doc(requestId)
        .update({'status': 'Accepted'});

    setState(() {
      status = 'Accepted'; // Instantly update local UI
    });
  }

  /// Rejects the request and updates UI instantly
  Future<void> rejectRequest() async {
    if (requestId == null) return;

    await fyre
        .collection('requests')
        .doc(requestId)
        .update({'status': 'Rejected'});

    setState(() {
      status = 'Rejected'; // Instantly update local UI
    });
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Accepted'
        ? Colors.green
        : status == 'Pending'
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        title:
            Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Status: $status", style: TextStyle(color: statusColor)),
        trailing: status == 'Accepted'
            ? Icon(Icons.arrow_forward_ios,
                size: 18, color: const Color.fromARGB(255, 51, 0, 255))
            : status == 'Rejected'
                ? IconButton(
                    onPressed: () async {
                      await fyre.collection('requests').doc(requestId).delete();
                    },
                    icon: Icon(Icons.block, size: 18, color: Colors.red))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: acceptRequest,
                        icon: Icon(Icons.check, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: rejectRequest,
                        icon: Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
        onTap: () {
          Get.to(Lawsuit(), transition: Transition.noTransition);
        },
      ),
    );
  }
}
