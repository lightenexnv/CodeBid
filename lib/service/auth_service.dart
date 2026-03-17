import 'package:codebid/utils/snackbarPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> logout() async {
    try {

      await GoogleSignIn().signOut();

      await FirebaseAuth.instance.signOut();

      SnackbarUtils.show("Logged Out", "Successfully");

    } catch (e) {
      SnackbarUtils.show("Logout Failed", "Try again");
    }
  }

  Future<User?> signInWithGoogle() async{
    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if(googleUser==null){
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    }catch(e){

      SnackbarUtils.show("Google Login Failed", "Try Again");
      return null;
    }
  }

  Future<User?> signInWithGithub() async{
    try{
      GithubAuthProvider gitHubProvider = GithubAuthProvider();
      UserCredential userCredential =await _auth.signInWithProvider(gitHubProvider);

      return userCredential.user;
    }catch(e){
      SnackbarUtils.show("GitHub Login Failed", "Try Again");
      return null;
    }
  }
}

