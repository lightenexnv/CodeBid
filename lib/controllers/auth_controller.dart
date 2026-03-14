import 'package:codebid/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController{
  final AuthService _service = AuthService();

  Future<User?> register(String email, String password)async{
    return await _service.signup(email, password);
  }

  Future<User?> login(String email, String password)async{
    return await _service.login(email, password);
  }

  Future<User?> logout()async{
    return await _service.logout();
  }

}