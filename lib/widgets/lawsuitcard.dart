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
      print("Updating request ($requestId) status to: $newStatus");

      await fyre
          .collection('requests')
          .doc(requestId)
          .update({'status': newStatus});

      print("Firestore update successful.");

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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Status: $status", style: TextStyle(color: statusColor)),
        trailing: status == 'Accepted'
            ? const Icon(Icons.arrow_forward_ios,
                size: 18, color: Color.fromARGB(255, 51, 0, 255))
            : status == 'Rejected'
                ? IconButton(
                    onPressed: () async {
                      if (requestId != null) {
                        await fyre
                            .collection('requests')
                            .doc(requestId)
                            .delete();
                        print("Deleted request: $requestId");
                      } else {
                        print("Error: requestId is null, cannot delete.");
                      }
                    },
                    icon: const Icon(Icons.block, size: 18, color: Colors.red))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => updateRequestStatus('Accepted'),
                        icon: const Icon(Icons.check, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () => updateRequestStatus('Rejected'),
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
        onTap: () {
          Get.to(() => const Lawsuit(), transition: Transition.noTransition);
        },
      ),
    );
  }
}
