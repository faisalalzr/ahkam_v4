import 'package:chat/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Lawyer extends Account {
  @override
  final String? uid;
  @override
  final String? name;
  @override
  final String email;
  final String? specialization;
  final double? rating;
  final String? province;
  @override
  final String? number;
  final String? licenseNO;
  final int? exp;
  final String? pic;
  @override
  bool? isLawyer;
  final String? desc;

  Lawyer(
      {this.uid,
      this.name,
      required this.email,
      this.specialization,
      this.rating,
      this.province,
      this.number,
      this.licenseNO,
      this.exp,
      this.pic,
      this.isLawyer,
      this.desc})
      : super(email: email);

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'specialization': specialization,
      'rating': rating,
      'province': province,
      'number': number,
      'licenseNO': licenseNO,
      'exp': exp,
      'pic': pic,
      'isLawyer': isLawyer,
      'desc': desc
    };
  }

  factory Lawyer.fromMap(Map<String, dynamic> map) {
    return Lawyer(
        uid: map['uid'],
        name: map['name'],
        email: map['email'],
        specialization: map['specialization'],
        rating: (map['rating'] as num?)?.toDouble(),
        province: map['province'],
        number: map['number'],
        licenseNO: map['licenceNO'],
        exp: map['exp'],
        pic: map['pic'],
        isLawyer: map['isLawyer'],
        desc: map['desc']);
  }

// Firestore collection reference
  static final CollectionReference lawyerCollection =
      FirebaseFirestore.instance.collection('account');

  // Add a lawyer to Firestore
  @override
  Future<void> addToFirestore() async {
    await lawyerCollection.add(toMap());
  }

  // Fetch all lawyers from Firestore
  static Future<List<Lawyer>> getLawyers() async {
    QuerySnapshot querySnapshot = await lawyerCollection.get();
    return querySnapshot.docs
        .map((doc) => Lawyer.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Update a lawyer's details in Firestore
  @override
  Future<void> updateInFirestore() async {
    if (uid != null) {
      await lawyerCollection.doc(uid).update(toMap());
    }
  }

  // Delete a lawyer from Firestore
  @override
  Future<void> deleteFromFirestore() async {
    if (uid != null) {
      await lawyerCollection.doc(uid).delete();
    }
  }
}
