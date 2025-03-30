import 'package:flutter/material.dart';

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5EEDC),
        title: Text(
          "Disclaimer",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 72, 47, 0),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white70,
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Text(
              "Ahkam provides a platform to connect users with lawyers, but we are not responsible for the accuracy or quality of the legal advice provided through the application. The content provided by lawyers is their own responsibility and does not constitute an official opinion or guidance from Ahkam. Your use of the service is at your own risk.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 72, 47, 0),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
