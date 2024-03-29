import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_firebase_2/modules/sign_up_page/models/user.dart';

class AuthenticationService {
  FirebaseAuth auth = FirebaseAuth.instance;

  Stream<UserModel> retrieveCurrentUser() {
    return auth.authStateChanges().map((User? user) {
      if (user != null) {
        return UserModel(
            uid: user.uid, email: user.email, displayName: user.displayName);
      } else {
        return UserModel(uid: "uid");
      }
    });
  }

  Future<String?> retrieveCurrentUserToken() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final userCredential = await user.getIdToken();
        return userCredential;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signUp(UserModel user) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: user.email!, password: user.password!);
      // await verifyEmail();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<UserCredential?> signIn(UserModel user) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: user.email!, password: user.password!);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<void> verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      return await user.sendEmailVerification();
    }
  }

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
