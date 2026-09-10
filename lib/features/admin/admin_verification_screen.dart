import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/media/safe_network_image.dart';

class AdminVerificationScreen extends StatelessWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy900,
        title: const Text('Property Verification', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('properties').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No properties listed yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final bool isVerified = data['isVerified'] ?? false;
              final String docId = docs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: SafeNetworkImage(
                    url: data['imageUrl'] ?? '',
                    width: 50,
                    height: 50,
                  ),
                  title: Text(
                    data['name'] ?? 'Unnamed Property',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isVerified ? 'Status: Verified' : 'Status: Unverified',
                    style: TextStyle(
                      color: isVerified ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  trailing: Switch(
                    value: isVerified,
                    activeTrackColor: AppColors.gold500,
                    onChanged: (val) {
                      FirebaseFirestore.instance
                          .collection('properties')
                          .doc(docId)
                          .update({'isVerified': val});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}