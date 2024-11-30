import 'package:bodo_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Existing register method
  Future<UserModel> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      id: credential.user!.uid,
      email: email,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toMap());

    return user;
  }

  // Add login method
  Future<UserModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    return UserModel.fromFirestore(doc);
  }

  // Add sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Add current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}