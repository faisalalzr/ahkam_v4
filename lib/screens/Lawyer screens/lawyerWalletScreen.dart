import 'package:chat/models/lawyer.dart';
import 'package:flutter/material.dart';

class lawyerWalletScreen extends StatefulWidget {
  final Lawyer lawyer;
  const lawyerWalletScreen({super.key, required this.lawyer});

  @override
  State<lawyerWalletScreen> createState() => _lawyerWalletScreenState();
}

class _lawyerWalletScreenState extends State<lawyerWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: 10),
              const ActionButtons(),
              const SizedBox(height: 20),
              Expanded(child: SingleChildScrollView(child: RequestCard())),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 18),
          const SizedBox(width: 4),
          Text('12:50', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Stack(
            children: [
              Icon(Icons.notifications_none, size: 28),
              Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text('3',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                "https://i.imgur.com/BoN9kdC.png"), // Replace with real profile image
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("هلا بك",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("بدر الدريعي", style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildBox(Icons.gavel, "تقاضي")),
          const SizedBox(width: 12),
          Expanded(
              child: _buildBox(Icons.chat_bubble_outline, "استشارة فورية")),
        ],
      ),
    );
  }

  Widget _buildBox(IconData icon, String title) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  const RequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('نشطة', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage("https://i.imgur.com/QCNbOAo.png"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("3.0", style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                      ],
                    ),
                    Text("عبدالرحمن التركي",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("تقاضي", style: TextStyle(color: Colors.white)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white30),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("تصنيف رئيسي: جنائي - تقاضي",
                    style: TextStyle(color: Colors.white70)),
                Text("رقم الطلب: 4842",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text("25 أبريل 2024", style: TextStyle(color: Colors.white70)),
                SizedBox(width: 16),
                Icon(Icons.access_time, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text("12:45 PM", style: TextStyle(color: Colors.white70)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xFF1E3A5F),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "طلباتي"),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet), label: "محفظتي"),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "المزيد"),
      ],
    );
  }
}
