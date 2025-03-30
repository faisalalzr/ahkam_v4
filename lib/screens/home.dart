import 'package:chat/models/account.dart';
import 'package:chat/models/lawyer.dart';
import 'package:chat/screens/about.dart';
import 'package:chat/screens/browse.dart';
import 'package:chat/screens/messagesScreen.dart';
import 'package:chat/screens/notification.dart';
import 'package:chat/screens/profile.dart';
import 'package:chat/screens/request.dart';
import 'package:chat/widgets/lawyer_card.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../widgets/category.dart';
import 'disclaimerPage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.account});
  final Account account;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 3;
  TextEditingController searchController = TextEditingController();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = NotificationsScreen(account: widget.account);
        break;
      case 1:
        nextScreen = MessagesScreen(account: widget.account);
        break;
      case 2:
        nextScreen = RequestsScreen(account: widget.account);
        break;
      case 3:
        return; // Prevent infinite navigation loop
      default:
        return;
    }

    Get.offAll(() => nextScreen, transition: Transition.noTransition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DrawerHeader(
              child: Image.asset(
                height: 150,
                width: 150,
                "assets/images/ehkaam-seeklogo.png",
                fit: BoxFit.contain,
              ),
            ),
            Text("Menu",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 72, 47, 0),
                  ),
                )),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Color.fromARGB(255, 72, 47, 0),
              ),
              title: Text("Disclaimer",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(255, 72, 47, 0),
                    ),
                  )),
              onTap: () => Get.to(DisclaimerPage()),
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: Color.fromARGB(255, 72, 47, 0),
              ),
              title: Text("About",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(255, 72, 47, 0),
                    ),
                  )),
              onTap: () => Get.to(AboutPage()),
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Color.fromARGB(255, 72, 47, 0),
              ),
              title: Text("Profile",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(255, 72, 47, 0),
                    ),
                  )),
              onTap: () => Get.to(ProfileScreen(account: widget.account),
                  transition: Transition.noTransition),
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Color.fromARGB(255, 72, 47, 0),
              ),
              title: Text("Settings",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(255, 72, 47, 0),
                    ),
                  )),
              onTap: () {},
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xFFF5EEDC),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // user profile pic,

            Text('Welcome, ${widget.account.name ?? 'user'}',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 72, 47, 0),
                  ),
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Get.to(DisclaimerPage(), transition: Transition.rightToLeft);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => BrowseLawyersScreen(''),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuart,
                    );
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 65),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 255, 194, 38),
                            Color.fromARGB(255, 220, 158, 0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 0.8],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            "Browse Lawyers",
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Text("Categories",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 30,
                    color: Color.fromARGB(255, 72, 47, 0),
                  ),
                )),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(category: categories[index]);
                },
              ),
            ),
            SizedBox(height: 5),
            Text("Top Lawyers",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 30,
                    color: Color.fromARGB(255, 72, 47, 0),
                  ),
                )),
            SizedBox(height: 10),
            FutureBuilder<List<Lawyer>>(
              future: Lawyer.getTopLawyers(limit: 1),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator()); // Loading spinner
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading lawyers"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No top-rated lawyers available"));
                }

                List<Lawyer> topLawyers = snapshot.data!;
                return Column(
                  children: topLawyers.map((lawyer) {
                    return LawyerCard(lawyer: lawyer);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromARGB(255, 72, 47, 0),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.bell), label: "Notifications"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageCircle), label: "Chat"),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
        ],
      ),
    );
  }
}
