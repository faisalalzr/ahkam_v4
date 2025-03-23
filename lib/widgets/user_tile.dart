import 'package:chat/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserTile extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;

  const UserTile(
      {super.key, required this.receiverID, required this.receiverEmail});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
          ChatScreen(receiverEmail: receiverEmail, receiverID: receiverID)),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 18.0, top: 8, bottom: 8, right: 8),
          child: Row(
            children: [
              //replace with image later on
              Icon(Icons.person)

              //username
              ,
              Text(
                receiverEmail,
                style: TextStyle(fontSize: 21),
              )
            ],
          ),
        ),
      ),
    );
  }
}
