import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat/models/lawyer.dart';

import '../widgets/LawyerCardBrowse.dart';

class BrowseLawyersScreen extends StatefulWidget {
  final String? search;

  const BrowseLawyersScreen(this.search, {super.key});

  @override
  State<BrowseLawyersScreen> createState() => _BrowseLawyersScreenState();
}

class _BrowseLawyersScreenState extends State<BrowseLawyersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  String _searchQuery = ''; // Local variable to manage search state

  @override
  void initState() {
    super.initState();
    // Initialize the search query with the initial search value
    _searchQuery = widget.search ?? '';
    searchController.text = _searchQuery;
  }

  @override
  Widget build(BuildContext context) {
    // Query setup for Firestore
    Query query =
        _firestore.collection('account').where('isLawyer', isEqualTo: true);

    if (_searchQuery.isNotEmpty) {
      query = _firestore
          .collection('account')
          .orderBy('name') // Ordering before filtering
          .where('isLawyer', isEqualTo: true)
          .startAt([_searchQuery]).endAt(['$_searchQuery\uf8ff']);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5EEDC),
        title: Text(
          "Browse Lawyers",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 72, 47, 0),
          ),
        ),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color.fromARGB(255, 72, 47, 0)),
            onPressed: () {
              setState(() {
                _searchQuery = searchController.text; // Update the search query
              });
              // Rebuild the UI with the updated search term
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                // Update the local search query as user types
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: InputDecoration(
                hintText: "Search for a lawyer...",
                prefixIcon: Icon(Icons.search, color: Color(0xFF3A3A3A)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                var lawyers = snapshot.data!.docs;
                if (lawyers.isEmpty) {
                  return Center(
                    child: Text(
                      'No lawyers found matching your search.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: lawyers.length,
                  itemBuilder: (context, index) {
                    var lawyerData =
                        lawyers[index].data() as Map<String, dynamic>;

                    Lawyer lawyer = Lawyer(
                      uid: lawyers[index].id,
                      name: lawyerData['name'] ?? 'Unknown',
                      email: lawyerData['email'] ?? 'Unknown',
                      specialization: lawyerData['specialization'] ?? 'Unknown',
                      rating: lawyerData['rating'] ?? 0.0,
                      province: lawyerData['province'] ?? 'Unknown',
                      number: lawyerData['number'] ?? 'N/A',
                      desc: lawyerData['desc'] ?? '',
                    );

                    return LawyerCardBrowse(lawyer: lawyer);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
