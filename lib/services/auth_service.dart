import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Endpoint backend FastAPI (menggunakan URL Vercel online agar bisa diakses dari HP fisik & luar emulator)
  static const String backendUrl = 'https://promob-backend.vercel.app';

  // Getter user saat ini
  User? get currentUser => _auth.currentUser;

  // Stream status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Sign In with Google ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Batal login

      // Ambil detail autentikasi dari request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Buat kredensial baru untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign-in ke Firebase Auth
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Ambil ID Token Firebase untuk verifikasi di Backend
        final String? idToken = await user.getIdToken();
        if (idToken != null) {
          await sendTokenToBackend(idToken);
        }
      }

      return userCredential;
    } catch (e) {
      print('Error Google Sign-In: $e');
      return null;
    }
  }

  // --- Sign In with Apple ---
  Future<UserCredential?> signInWithApple() async {
    try {
      // Trigger Apple Sign-In flow
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Buat kredensial OAuthProvider untuk Firebase
      final AuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: null, // Nonce opsional
      );

      // Sign-in ke Firebase Auth
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final String? idToken = await user.getIdToken();
        if (idToken != null) {
          await sendTokenToBackend(idToken);
        }
      }

      return userCredential;
    } catch (e) {
      print('Error Apple Sign-In: $e');
      return null;
    }
  }

  // --- Kirim ID Token ke FastAPI Backend ---
  Future<void> sendTokenToBackend(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        print('Koneksi Backend Sukses: Akun aktif di database server.');
      } else {
        print('Gagal sinkronisasi ke backend: ${response.body}');
      }
    } catch (e) {
      print('Error menghubungi backend server: $e');
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
