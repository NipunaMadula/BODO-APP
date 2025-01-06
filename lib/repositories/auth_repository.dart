import 'package:bodo_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<UserModel> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: null, // Will be updated in verify screen
        phone: null, // Will be updated in verify screen
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        throw 'An account already exists for that email';
      } else {
        throw 'Registration failed: ${e.message}';
      }
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided';
      } else {
        throw 'Login failed: ${e.message}';
      }
    } catch (e) {
      throw 'Login failed: $e';
    }
  }

    Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email';
      }
      throw e.message ?? 'Failed to send reset email';
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Sign in cancelled';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);    
      final user = userCredential.user;
      if (user == null) throw 'Failed to sign in';

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName,
          phone: null,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap());
        return newUser;
      }

      return UserModel.fromFirestore(userDoc);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw 'Account exists with different sign in method';
      }
      throw e.message ?? 'Google sign in failed';
    } catch (e) {
      throw 'Failed to sign in with Google';
    }
  }

  // Update user details
  Future<void> updateUserDetails(String userId, {String? name, String? phone}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            if (name != null) 'name': name,
            if (phone != null) 'phone': phone,
          });
    } catch (e) {
      throw 'Failed to update user details: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}