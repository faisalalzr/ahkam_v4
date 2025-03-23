import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/message.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a stream of user data from Firestore.
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("account").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Sends a message to the given receiver.
  Future<void> sendMessage(String receiverId, String message) async {
    // Validate that the message is not empty or just whitespace.
    if (message.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently logged in.");
    }
    final String currentUserID = currentUser.uid;
    final String? currentUserEmail = currentUser.email;
    if (currentUserEmail == null) {
      throw Exception("Current user's email is null.");
    }
    final Timestamp timestamp = Timestamp.now();

    // Create a new message instance.
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Construct chatroom id by sorting the user IDs.
    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatroomId = ids.join('_');

    // Add the new message to Firestore.
    try {
      await _firestore
          .collection("chat_rooms")
          .doc(chatroomId)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String userID, String otherID) {
    List<String> ids = [userID, otherID];
    ids.sort();
    String chatroomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
