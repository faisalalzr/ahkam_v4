import 'package:chat/screens/browse.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lucide_icons/lucide_icons.dart';

class Category {
  final String name;
  final IconData icon;
  Category({required this.name, required this.icon});
}

List<Category> categories = [
  Category(name: "Criminal", icon: LucideIcons.shield),
  Category(name: "Commercial", icon: LucideIcons.scale),
  Category(name: "Insurance", icon: LucideIcons.briefcase),
  Category(name: "International", icon: LucideIcons.globe),
  Category(name: "Labor", icon: LucideIcons.badge),
  Category(name: "Civil", icon: LucideIcons.book),
];

class CategoryCard extends StatelessWidget {
  final Category category;
  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(BrowseLawyersScreen(null));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 246, 236, 206),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 32,
              color: Color.fromARGB(255, 72, 47, 0),
            ),
            SizedBox(height: 5),
            Text(category.name,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 72, 47, 0),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
