import 'package:chat/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.windows,
  );

  User? user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        theme: ThemeData(
            primaryColor: Color(0xFFF5EEDC),
            scaffoldBackgroundColor: Colors.white,
            buttonTheme: ButtonThemeData(
              buttonColor: Color(0xFFF5EEDC),
            )),
        debugShowCheckedModeBanner: false,
        home: LoginScreen());
  }
}
