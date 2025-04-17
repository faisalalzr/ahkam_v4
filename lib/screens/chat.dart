import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void showRatingDialog(
    BuildContext context, String rid, String lawyerId, String reviewerId) {
  double rating = 3;
  TextEditingController reviewController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Rate the Lawyer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                rating = value;
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: reviewController,
              decoration: InputDecoration(
                hintText: 'Leave a review...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Submit'),
            onPressed: () async {
              String review = reviewController.text.trim();

              try {
                await FirebaseFirestore.instance.collection('reviews').add({
                  'rid': rid,
                  'lawyerId': lawyerId,
                  'reviewerId': reviewerId,
                  'rating': rating,
                  'review': review,
                  'timestamp': Timestamp.now(),
                });

                Get.snackbar("Thank You", "Your review has been submitted.");
              } catch (e) {
                Get.snackbar("Error", "Failed to submit review: $e");
              }

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// ✅ This ensures the dialog is shown only once
bool _hasShownRatingDialog = false;

class Chat extends StatefulWidget {
  final String receiverID;
  final String receivername;
  final String rid;
  final String senderId;

  const Chat({
    super.key,
    required this.receiverID,
    required this.receivername,
    required this.rid,
    required this.senderId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Chat> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _isSendingMessage = false.obs;

  bool hasEnded = false;
  bool isLawyer = false;
  DocumentReference<Map<String, dynamic>>? requestRef;

  @override
  void initState() {
    super.initState();
    _loadRequestStatus();
  }

  Future<void> _loadRequestStatus() async {
    final userId = _authService.getCurrentUser()?.uid;
    if (userId == null) return;

    final query = await FirebaseFirestore.instance
        .collection('requests')
        .where('rid', isEqualTo: widget.rid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      requestRef = doc.reference;

      final ended = doc['ended?'] ?? false;
      final lawyer = doc['lawyerId'] == userId;

      setState(() {
        hasEnded = ended;
        isLawyer = lawyer;
      });

      if (ended && !lawyer && !_hasShownRatingDialog) {
        _hasShownRatingDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showRatingDialog(context, widget.rid, widget.receiverID, userId);
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (hasEnded) {
      Get.snackbar("Consultation Ended", "You cannot send messages anymore.");
      return;
    }

    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    _isSendingMessage.value = true;
    try {
      await _chatService.sendMessage(
          widget.senderId, widget.receiverID, message);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: $e");
    } finally {
      _isSendingMessage.value = false;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            SizedBox(width: 10),
            Text(
              widget.receivername,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: const Color.fromARGB(255, 108, 79, 0)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          if (isLawyer && !hasEnded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (requestRef != null) {
                    await requestRef!.update({'ended?': true});
                    setState(() {
                      hasEnded = true;
                    });
                    Get.snackbar(
                        "Consultation Ended", "The chat is now closed.");
                  }
                },
                icon: Icon(Icons.stop_circle),
                label: Text("End Consultation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          Expanded(child: buildMessageList()),
          buildMessageInputField(),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    User? currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      return Center(child: Text("Error: User not found"));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _chatService.getMessages(widget.senderId, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages yet."));
        }

        List<DocumentSnapshot<Map<String, dynamic>>> messageDocs =
            snapshot.data!.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: messageDocs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messageDocs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();
    if (data == null) return SizedBox.shrink();
    bool isMe = data["senderID"] == widget.senderId;

    Timestamp timestamp = data["timestamp"];
    String formattedTime = formatTimestamp(timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data["message"] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget buildMessageInputField() {
    if (hasEnded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 50.0, right: 10, left: 10),
        child: Column(
          children: [
            Text(
              "This consultation has ended. You can no longer send messages.",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Message...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: IconButton(
              icon: Icon(Icons.document_scanner, size: 18, color: Colors.black),
              onPressed: () {},
            ),
          ),
          SizedBox(width: 4),
          Obx(() {
            return GestureDetector(
              onTap: _isSendingMessage.value ? null : _sendMessage,
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 117, 84, 0),
                radius: 17,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
