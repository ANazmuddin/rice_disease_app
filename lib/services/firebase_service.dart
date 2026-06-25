import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // 1. Fungsi Autentikasi
  static Future<User?> login(String email, String password) async {
    UserCredential cred = await auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  static Future<User?> register(String email, String password) async {
    UserCredential cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  static Future<void> logout() async {
    await auth.signOut();
  }

  // 2. Fungsi Menyimpan Hasil Analisis ke Database
  static Future<void> saveHistory({
    required String disease,
    required double confidence,
    required String base64Image,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Sesi login telah habis.');

    // Simpan ke collection khusus milik user yang sedang login
    await db.collection('users').doc(user.uid).collection('history').add({
      'disease': disease,
      'confidence': confidence,
      'image': base64Image,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 3. Fungsi Mengambil Riwayat (Stream agar Real-time)
  static Stream<QuerySnapshot> getHistoryStream() {
    final user = auth.currentUser;
    if (user == null) throw Exception('Sesi login telah habis.');

    return db.collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}