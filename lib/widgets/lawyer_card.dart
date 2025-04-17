import 'package:chat/models/lawyer.dart';
import 'package:chat/screens/lawyerdetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LawyerCard extends StatelessWidget {
  final Lawyer lawyer;
  const LawyerCard({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            radius: 25,
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
                    fontSize: 15,
                    color: Colors.brown[900],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      "${lawyer.rating ?? 0.0} (${(lawyer.rating ?? 0).toInt()} Reviews)",
                      style: GoogleFonts.lato(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lawyer.specialization ?? 'Legal Expert',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
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
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              backgroundColor: const Color.fromARGB(255, 246, 236, 206),
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
