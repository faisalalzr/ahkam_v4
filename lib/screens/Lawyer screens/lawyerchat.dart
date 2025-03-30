import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class Lawyerchat extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const Lawyerchat({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Lawyerchat> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _isSendingMessage = false.obs;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when messages are first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    _isSendingMessage.value = true;
    try {
      await _chatService.sendMessage(widget.receiverID, message);
      _messageController.clear();
      _scrollToBottom(); // Scroll to bottom after sending a message
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
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blueAccent),
            ),
            SizedBox(width: 10),
            Text(
              widget.receiverEmail,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
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
      stream: _chatService.getMessages(currentUser.uid, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages yet."));
        }

        List<DocumentSnapshot<Map<String, dynamic>>> messageDocs =
            snapshot.data!.docs;

        // Delay scrolling after new messages are built
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
    bool isMe = data["senderID"] == _authService.getCurrentUser()?.uid;

    Timestamp timestamp = data["timestamp"];
    String formattedTime = formatTimestamp(timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
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
    return "${dateTime.hour}:${dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute}";
  }

  Widget buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
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
          Obx(() {
            return GestureDetector(
              onTap: _isSendingMessage.value ? null : _sendMessage,
              child: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 25,
                child: Icon(Icons.send, color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }
}
