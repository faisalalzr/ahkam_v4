import 'package:chat/screens/Lawyer%20screens/lawyerHomeScreen.dart';
import 'package:chat/screens/home.dart';
import 'package:chat/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/account.dart';
import '../models/lawyer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _isLoading = false.obs;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }

    _isLoading.value = true;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? anyUser = userCredential.user;
      if (anyUser == null) throw Exception("User not found.");

      QuerySnapshot userQuery = await _firestore
          .collection('account')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception("User not found in Firestore.");
      }

      DocumentSnapshot userDoc = userQuery.docs.first;
      bool isLawyer =
          (userDoc.data() as Map<String, dynamic>?)?['isLawyer'] ?? false;

      if (isLawyer) {
        Get.off(() => LawyerHomeScreen(lawyer: Lawyer(email: anyUser.email!)));
      } else {
        Get.off(() => HomeScreen(account: Account(email: anyUser.email!)));
      }
    } catch (e) {
      _showError("Login failed: ${e.toString().split('] ').last}");
    } finally {
      _isLoading.value = false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ Prevents keyboard overflow
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderText(),
              SizedBox(height: 30),
              _buildTextField(_emailController, "Email", Icons.email, false),
              SizedBox(height: 16),
              _buildTextField(
                  _passwordController, "Password", Icons.lock, true),
              SizedBox(height: 24),
              _buildLoginButton(),
              SizedBox(height: 16),
              _buildRegisterOption(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      toolbarHeight: 100,
      title: Text(
        "AHKAM",
        style: TextStyle(
          fontSize: 40,
          fontFamily: 'Times New Roman',
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 72, 47, 0),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Login to continue",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isObscure) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 21, color: Color.fromARGB(255, 72, 47, 0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () {
        Future.delayed(Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.pixels,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      },
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => ElevatedButton(
          onPressed: _isLoading.value ? null : _login,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Color.fromARGB(255, 72, 47, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: _isLoading.value
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ));
  }

  Widget _buildRegisterOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?"),
        TextButton(
          onPressed: () =>
              Get.to(RegisterScreen(), transition: Transition.rightToLeft),
          child: Text("Sign up"),
        ),
      ],
    );
  }
}
