import 'package:flutter/material.dart';

import '../../models/lawyer.dart';

class Lawyernotiscreen extends StatefulWidget {
  final Lawyer lawyer;
  const Lawyernotiscreen({super.key, required this.lawyer});

  @override
  State<Lawyernotiscreen> createState() => _LawyernotiscreenState();
}

class _LawyernotiscreenState extends State<Lawyernotiscreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [],
      ),
    );
  }
}
