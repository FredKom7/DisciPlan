import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.g.dart';

@HiveType(typeId: 10)
class UserModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? phoneNumber;

  @HiveField(3)
  String displayName;

  @HiveField(4)
  String? photoURL;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  List<String> authProviders; // ['email', 'phone', 'google']

  UserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    required this.displayName,
    this.photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? authProviders,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        authProviders = authProviders ?? [];

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'authProviders': authProviders,
    };
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      displayName: data['displayName'] ?? 'User',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authProviders: List<String>.from(data['authProviders'] ?? []),
    );
  }

  // Create from Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    final providers = <String>[];
    for (var info in firebaseUser.providerData) {
      if (info.providerId == 'password') providers.add('email');
      if (info.providerId == 'phone') providers.add('phone');
      if (info.providerId == 'google.com') providers.add('google');
    }

    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      phoneNumber: firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
      photoURL: firebaseUser.photoURL,
      authProviders: providers,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? authProviders,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authProviders: authProviders ?? this.authProviders,
    );
  }
}
