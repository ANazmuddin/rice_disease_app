import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Riwayat Deteksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async => await FirebaseService.logout(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan data.'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pemindaian.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final diseaseName = data['disease'].toString().toUpperCase().replaceAll('_', ' ');
              final date = data['timestamp'] != null 
                  ? (data['timestamp'] as Timestamp).toDate().toString().split('.')[0]
                  : 'Baru saja';

              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(base64Decode(data['image']), width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  title: Text(diseaseName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  subtitle: Text('Kepercayaan: ${data['confidence']}%\n$date'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}