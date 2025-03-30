import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double logoSize = screenWidth * 0.4;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Us",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 72, 47, 0),
          ),
        ),
        backgroundColor: Color(0xFFF5EEDC),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white70,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                "assets/images/ehkaam-seeklogo.png",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Legal Connect",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "App version: 1.1.0",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.black38),
            ListTile(
              leading: Icon(Icons.email, color: Colors.black),
              title: Text("Contact us", style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.link, color: Colors.black),
              title: Text("Official website",
                  style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.facebook, color: Colors.black),
              title: Text("Follow us on Facebook",
                  style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
