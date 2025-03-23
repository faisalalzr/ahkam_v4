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
    return GestureDetector(
      onTap: () {
        Get.to(LawyerDetailsScreen(lawyer: lawyer),
            transition: Transition.fade);
      },
      child: Card(
        elevation: 15,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  lawyer.pic ?? 'assets/images/brad.webp',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lawyer.name!,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 72, 47, 0),
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 18),
                        Text("${lawyer.rating} (${lawyer.rating} Reviews)",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
