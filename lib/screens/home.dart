import 'package:chat/models/account.dart';
import 'package:chat/screens/browse.dart';
import 'package:chat/screens/messagesScreen.dart';
import 'package:chat/screens/notification.dart';
import 'package:chat/screens/profile.dart';
import 'package:chat/screens/request.dart';
import 'package:chat/screens/wallet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../widgets/lawyer_card.dart';
import '../widgets/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.account});
  final Account account;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSideBarOpen = false;
  int _selectedIndex = 4;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      switch (_selectedIndex) {
        case 0:
          Get.off(NotificationsScreen(account: widget.account),
              transition: Transition.noTransition);
          break;
        case 1:
          Get.off(WalletScreen(account: widget.account),
              transition: Transition.noTransition);
          break;
        case 2:
          Get.off(MessagesScreen(account: widget.account),
              transition: Transition.noTransition);
          break;
        case 3:
          Get.off(RequestsScreen(account: widget.account),
              transition: Transition.noTransition);
          break;
        case 4:
          Get.off(HomeScreen(account: widget.account),
              transition: Transition.noTransition);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DrawerHeader(child: Icon(Icons.scale_rounded)),
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(255, 72, 47, 0),
                          blurRadius: 5,
                          spreadRadius: 1)
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          Get.to(BrowseLawyersScreen(''),
                              transition: Transition.noTransition);
                        },
                        color: Color.fromARGB(255, 72, 47, 0),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
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
                GridView.builder(
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
                SizedBox(height: 20),
                Text("Top Lawyers",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(255, 72, 47, 0),
                      ),
                    )),
                SizedBox(height: 10),
                Column(
                    //  children: lawyers.map((e) => LawyerCard(lawyer: e)).toList(),
                    ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromARGB(255, 72, 47, 0),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bell),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet),
            label: "Wallet",
          ),
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
