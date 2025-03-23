import 'package:chat/models/lawyer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LawyerDetailsScreen extends StatefulWidget {
  final Lawyer? lawyer;
  const LawyerDetailsScreen({super.key, required this.lawyer});

  @override
  State<LawyerDetailsScreen> createState() => _LawyerDetailsScreenState();
}

class _LawyerDetailsScreenState extends State<LawyerDetailsScreen> {
  final TextEditingController _titleCont = TextEditingController();
  final TextEditingController _descriptionCont = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  FirebaseFirestore fyre = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getinfo() async {
    var querysnapshot = await fyre
        .collection('account')
        .where('email', isEqualTo: widget.lawyer!.email)
        .limit(1)
        .get();
    return querysnapshot.docs.first;
  }

  // Method to show the Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? currentDate,
      firstDate: currentDate,
      lastDate: DateTime(currentDate.year + 1),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.year}-${picked.month}-${picked.day}';
      });
    }
  }

  // Method to show the Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _sendRequest() async {
    if (_selectedDate == null || _selectedTime == null) {
      // Show an error if date or time is not selected
      Get.snackbar('Error', 'Please select both a date and time.');
      return;
    }

    // Get the current user (assuming the user is logged in)
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to send a request.');
      return;
    }

    // Create a request object
    final request = {
      'rid': '${currentUser.uid}${widget.lawyer!.uid}',
      'userId': currentUser.uid,
      'lawyerId': widget.lawyer!.uid,
      'title': _titleCont.text,
      'desc': _descriptionCont.text,
      'date': _selectedDate!.toIso8601String(),
      'time': _selectedTime!.format(context),
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Save the request to Firestore
    try {
      await fyre.collection('requests').add(request);
      Get.snackbar('Success', 'Consultation request sent successfully.');
      Get.back(); // Close the dialog
    } catch (e) {
      Get.snackbar('Error', 'Failed to send request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5EEDC),
        title: Text('Lawyer Details'),
      ),
      body: FutureBuilder(
        future: getinfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text('no data'),
            );
          }
          var userData = snapshot.data!.data() ?? {};
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lawyer Image
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        widget.lawyer?.pic ??
                            'assets/images/brad.webp', // Add your image here
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Lawyer Name
                  Text(
                    userData['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  Text(
                    'Specialization: ${userData['specialization']}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    userData['desc'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Contact Info:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Phone: ${widget.lawyer!.number!}\nEmail: ${widget.lawyer!.email}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Request Consultation Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Consultation Request',
                                style: TextStyle(fontSize: 20),
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // title
                                  TextField(
                                    controller: _titleCont,
                                    decoration: InputDecoration(
                                      labelText: ' title',
                                      suffixIcon: Icon(Icons.abc),
                                    ),
                                  ),
                                  SizedBox(height: 16),

                                  // description
                                  TextFormField(
                                    maxLines: null, // Allows multiline input
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      labelText: 'Description',
                                      suffixIcon: Icon(Icons.abc),
                                      hintText:
                                          "include all details of you case here",
                                      hintStyle: TextStyle(
                                          color: const Color.fromARGB(
                                              107, 63, 63, 63)),
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: _descriptionCont,
                                  ),
                                  SizedBox(height: 16),

                                  // Date Picker
                                  TextField(
                                    controller: _dateController,
                                    decoration: InputDecoration(
                                      labelText: 'Select Date',
                                      labelStyle: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 105, 105, 105)),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                  ),
                                  SizedBox(height: 16),

                                  // Time Picker
                                  TextField(
                                    controller: _timeController,
                                    decoration: InputDecoration(
                                      labelText: 'Select Time',
                                      suffixIcon: Icon(Icons.access_time),
                                    ),
                                    readOnly: true,
                                    onTap: () => _selectTime(context),
                                  ),
                                  SizedBox(height: 24),

                                  // Submit Button for Consultation
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Ensure both date and time are selected
                                        if (_selectedDate != null &&
                                            _selectedTime != null) {
                                          _sendRequest();
                                          navigator?.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Consultation Request'),
                                                content: Text(
                                                  'You have requested a consultation on ${_selectedDate!.toLocal()} at ${_selectedTime!.format(context)}.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          // Show an error dialog if date or time is not selected
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Error'),
                                                content: Text(
                                                    'Please select both a date and time.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                      ),
                                      child: Text(
                                        'Submit',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        'Request Consultation',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
