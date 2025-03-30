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
    return GestureDetector(
      onTap: () {
        Get.to(LawyerDetailsScreen(lawyer: lawyer),
            transition: Transition.fade);
      },
      child: Card(
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
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
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(height: 4),
                    lawyer.desc!.length < 25
                        ? Text(lawyer.desc ?? '',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ))
                        : Text('${lawyer.desc!.substring(0, 25)}...' ?? '',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            )),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 18),
                        Text("${lawyer.rating} ",
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
