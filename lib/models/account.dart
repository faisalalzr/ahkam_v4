import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String? uid; // Added the uid field
  final String? name;
  final String email;
  bool? isLawyer;
  final String? number;
  String? profileImage;

  Account({
    this.uid,
    this.name,
    required this.email,
    this.number,
    this.profileImage,
    this.isLawyer,
  });

  // A method to map Firestore data into a User object
  factory Account.fromMap(Map<String, dynamic> data) {
    return Account(
      uid: data['uid'] ?? '', // Use the docID as the uid
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profileImage: data['profileImage'] ?? '',
      number: data['number'] ?? '',
      isLawyer: data['isLawyer'] ?? false,
    );
  }

  // A method to convert a User object into a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'number': number,
      'profileImage': profileImage,
      'isLawyer': isLawyer,
    };
  }

  static final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('account');

  Future<void> addToFirestore() async {
    // When adding, use the UID as the document ID
    await userCollection.doc(uid).set(toMap());
  }

  Future<List<Account>> getUsers() async {
    QuerySnapshot snap = await userCollection.get();
    return snap.docs
        .map((doc) => Account.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Update a user's details in Firestore
  Future<void> updateInFirestore() async {
    if (uid!.isNotEmpty) {
      await userCollection.doc(uid).update(toMap());
    }
  }

  // Delete a user from Firestore
  Future<void> deleteFromFirestore() async {
    if (uid!.isNotEmpty) {
      await userCollection.doc(uid).delete();
    }
  }
}
