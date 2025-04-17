import 'package:chat/models/lawyer.dart';
import 'package:chat/screens/lawyerdetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LawyerCardBrowse extends StatelessWidget {
  final Lawyer lawyer;
  const LawyerCardBrowse({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Lawyer Profile Pic or Placeholder
          CircleAvatar(
            radius: 30,
            backgroundImage: lawyer.pic != null
                ? AssetImage(lawyer.pic!)
                : const AssetImage('assets/images/brad.webp'),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 16),

          // Lawyer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lawyer.name ?? 'Unknown Lawyer',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      "${lawyer.rating ?? 0.0} (${(lawyer.rating ?? 0).toInt()} Reviews)",
                      style: GoogleFonts.lato(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lawyer.specialization ?? 'Legal Expert',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // View Button
          ElevatedButton(
            onPressed: () {
              Get.to(() => LawyerDetailsScreen(lawyer: lawyer),
                  transition: Transition.fade);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 72, 45, 0),
              backgroundColor: const Color.fromARGB(255, 255, 241, 219),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: GoogleFonts.lato(fontSize: 12),
            ),
            child: Text("View", style: GoogleFonts.lato()),
          )
        ],
      ),
    );
  }
}
