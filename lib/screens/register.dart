import 'package:chat/screens/login.dart';
import 'package:chat/screens/new.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Register the user with Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      var uid = userCredential.user!.uid;

      // Navigate to next screen after successful registration
      Get.to(New(email: _emailController.text.trim(), uid: uid));
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed!';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password must be at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
      child: Scaffold(
        resizeToAvoidBottomInset: true, // ✅ Prevents overflow
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderText(),
                  SizedBox(height: 30),
                  _buildTextField(
                      _emailController, "Email", Icons.email, false),
                  SizedBox(height: 20),
                  _buildTextField(
                      _passwordController, "Password", Icons.lock, true),
                  SizedBox(height: 20),
                  _buildTextField(_confirmPasswordController,
                      "Confirm Password", Icons.lock, true),
                  SizedBox(height: 24),
                  _buildRegisterButton(),
                  SizedBox(height: 16),
                  _buildSignInOption(),
                ],
              ),
            ),
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
          "Create an Account!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Register to get started",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isObscure) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 21, color: Color.fromARGB(255, 72, 47, 0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label cannot be empty.";
        }
        if (label == "Email" &&
            !RegExp(r"^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$")
                .hasMatch(value)) {
          return "Enter a valid email.";
        }
        if ((label == "Password" || label == "Confirm Password") &&
            value.length < 6) {
          return "Password must be at least 6 characters.";
        }
        if (label == "Confirm Password" && value != _passwordController.text) {
          return "Passwords do not match.";
        }
        return null;
      },
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

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Color.fromARGB(255, 72, 47, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
              "Register",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildSignInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?"),
        TextButton(
          onPressed: () =>
              Get.off(LoginScreen(), transition: Transition.leftToRight),
          child: Text("Sign In"),
        ),
      ],
    );
  }
}
