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
  final String? fees;

  Lawyer({
    this.uid,
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
    this.desc,
    this.fees,
  }) : super(email: email);

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
      'desc': desc,
      'fees': fees,
    };
  }

  factory Lawyer.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Lawyer(
      uid: doc.id, // Use Firestore document ID
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? '',
      specialization: map['specialization'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0, // Default 0.0 if null
      province: map['province'],
      number: map['number'],
      licenseNO: map['licenseNO'],
      exp: map['exp'] ?? 0,
      pic: map['pic'],
      isLawyer: map['isLawyer'] ?? false,
      desc: map['desc'],
      fees: map['fees'],
    );
  }

  static final CollectionReference lawyerCollection =
      FirebaseFirestore.instance.collection('account');

  @override
  Future<void> addToFirestore() async {
    await lawyerCollection.add(toMap());
  }

  /// **Fetch Top-Rated Lawyers**
  static Future<List<Lawyer>> getTopLawyers({int limit = 1}) async {
    QuerySnapshot querySnapshot = await lawyerCollection
        .where('isLawyer', isEqualTo: true)
        //.orderBy('rating', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) => Lawyer.fromFirestore(doc)).toList();
  }
}
