import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/lawyer.dart';
import 'lawyerHomeScreen.dart';
import 'lawyerMessages.dart';
import 'lawyerWalletScreen.dart';

class Morelawyer extends StatefulWidget {
  final Lawyer lawyer;
  const Morelawyer({super.key, required this.lawyer});

  @override
  State<Morelawyer> createState() => _Morelawyer();
}

class _Morelawyer extends State<Morelawyer> {
  var _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.bell), label: "Notifications"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.wallet), label: "Wallet"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageCircle), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
        ],
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text('more')],
      ),
    );
  }

  void onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Get.off(() => Morelawyer(lawyer: widget.lawyer),
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
