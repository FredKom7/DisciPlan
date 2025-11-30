import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Create user model
      final userModel = UserModel.fromFirebaseUser(userCredential.user!);
      userModel.displayName = displayName;

      // Save to Firestore
      await _saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await _getUserFromFirestore(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up/Sign in with phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
    required Function(UserModel user) verificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          final userModel = await _getOrCreateUser(userCredential.user!);
          verificationCompleted(userModel);
        } catch (e) {
          verificationFailed(e.toString());
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(_handleAuthException(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify OTP code
  Future<UserModel?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return await _getOrCreateUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete all user collections
      final collections = ['todos', 'habits', 'tasks', 'screenTime', 'restrictions'];
      for (final collection in collections) {
        final snapshot = await _firestore
            .collection(collection)
            .where('userId', isEqualTo: user.uid)
            .get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw 'Failed to delete account: $e';
    }
  }

  // Link email to existing account
  Future<void> linkEmailToAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': email,
        'authProviders': FieldValue.arrayUnion(['email']),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Private: Save user to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  // Private: Get user from Firestore
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Private: Get or create user
  Future<UserModel> _getOrCreateUser(User firebaseUser) async {
    var userModel = await _getUserFromFirestore(firebaseUser.uid);
    
    if (userModel == null) {
      userModel = UserModel.fromFirebaseUser(firebaseUser);
      await _saveUserToFirestore(userModel);
    }
    
    return userModel;
  }

  // Private: Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please use at least 8 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Verification session expired. Please request a new code.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
