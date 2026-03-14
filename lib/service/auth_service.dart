import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signup(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      SnackbarUtils.show("Account Not Created", "Check Credentials");
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      SnackbarUtils.show("Login Failed", "Check email and password");
      return null;
    }
  }

  Future<User?> logout() async {
    try{
      await _auth.signOut();
      SnackbarUtils.show("Logged Out", "Successfully");
    }catch(e){
    SnackbarUtils.show("Log Out", "UnSuccessFully");
  }}
}

//demo commit