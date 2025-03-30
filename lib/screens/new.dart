import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/lawyer.dart';
import '../models/account.dart';
import 'home.dart';
import 'Lawyer screens/lawyerHomeScreen.dart';

class New extends StatefulWidget {
  const New({super.key, required this.email, required this.uid});
  final String email;
  final String uid;

  @override
  State<New> createState() => _NewState();
}

class _NewState extends State<New> {
  bool isChecked = false;
  bool isLawyer = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _licenseNoController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController provinceCont = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController feesController = TextEditingController();

  final List<String> professions = [
    "Civil Law",
    "Criminal Law",
    "Corporate Law"
  ];
  String? _selectedProfession;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text('Complete Sign-Up',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
      ),
      body: isSubmitting
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserSelection(),
                    const SizedBox(height: 20),
                    Center(child: _buildProfileImage()),
                    const SizedBox(height: 20),
                    _buildUserFields(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSelectionButton("I'm a Client", Icons.person, false),
        _buildSelectionButton("I'm a Lawyer", Icons.gavel, true),
      ],
    );
  }

  Widget _buildSelectionButton(String text, IconData icon, bool selected) {
    bool isSelected = (isLawyer == selected);
    return GestureDetector(
      onTap: () => setState(() => isLawyer = selected),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurpleAccent : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: Colors.deepPurpleAccent, blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 50, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 10),
            Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: pickImage,
      child: CircleAvatar(
        radius: 55,
        backgroundColor: Colors.deepPurpleAccent,
        backgroundImage:
            _selectedImage != null ? FileImage(_selectedImage!) : null,
        child: _selectedImage == null
            ? Icon(Icons.camera_alt, color: Colors.white, size: 30)
            : null,
      ),
    );
  }

  Widget _buildUserFields() {
    return Column(
      children: [
        _buildInputField("Full Name", _nameController,
            validator: (val) => val!.isEmpty ? 'Please enter your name' : null),
        const SizedBox(height: 15),
        _buildInputField("Phone Number", _phoneNumberController,
            keyboardType: TextInputType.phone, validator: (val) {
          if (val!.isEmpty) return 'Please enter a phone number';
          return null;
        }),
        if (isLawyer) ...[
          const SizedBox(height: 15),
          _buildDropdownField("Profession", _selectedProfession, professions,
              (val) => setState(() => _selectedProfession = val)),
          const SizedBox(height: 15),
          _buildInputField("Years of Experience", _experienceController,
              keyboardType: TextInputType.number, validator: (val) {
            if (val!.isEmpty) return 'Please enter years of experience';
            return null;
          }),
          const SizedBox(height: 15),
          _buildInputField("License Number", _licenseNoController,
              validator: (val) {
            if (val!.isEmpty) return 'Please enter your license number';
            return null;
          }),
          const SizedBox(height: 15),
          _buildInputField("Description", descController, validator: (val) {
            if (val!.isEmpty) return 'Please provide a description';
            return null;
          }),
          const SizedBox(height: 15),
          _buildInputField("Consultation Fee", feesController,
              keyboardType: TextInputType.number, validator: (val) {
            if (val!.isEmpty) return 'Please enter your consultation fee';
            return null;
          }),
          const SizedBox(height: 15),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: _submitForm,
      child: const Center(
        child:
            Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    String imageUrl = "";
    if (_selectedImage != null) {
      try {
        imageUrl = await uploadProfilePic(_selectedImage!);
      } catch (e) {
        setState(() => isSubmitting = false);
        showError('Failed to upload image. Please try again.');
        return;
      }
    }

    try {
      if (!isLawyer) {
        Account user = Account(
            uid: widget.uid,
            isLawyer: false,
            name: _nameController.text,
            email: widget.email,
            number: _phoneNumberController.text);
        await user.addToFirestore();
        Get.to(HomeScreen(account: user));
      } else {
        Lawyer lawyer = Lawyer(
          uid: widget.uid,
          name: _nameController.text,
          email: widget.email,
          number: _phoneNumberController.text,
          licenseNO: _licenseNoController.text,
          exp: int.parse(_experienceController.text),
          specialization: _selectedProfession,
          isLawyer: isLawyer,
          desc: descController.text,
          fees: feesController.text,
        );
        await lawyer.addToFirestore();
        Get.to(LawyerHomeScreen(lawyer: lawyer));
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      showError('Failed to submit. Please try again.');
    }
  }

  Future<String> uploadProfilePic(File image) async {
    String fileName =
        "profile_pics/${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    TaskSnapshot snapshot = await ref.putFile(image);
    return await snapshot.ref.getDownloadURL();
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items,
      void Function(String?)? onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
