import 'package:firebase_auth/firebase_auth.dart';
import 'package:darkness_dungeon/util/logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login con Email y Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      GameLogger.info('Usuario logueado: ${credential.user?.email}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      GameLogger.error('Error en login: ${e.code}');
      rethrow;
    }
  }

  // Registro con Email y Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      GameLogger.info('Usuario registrado: ${credential.user?.email}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      GameLogger.error('Error en registro: ${e.code}');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    GameLogger.info('Sesión cerrada');
  }
}
