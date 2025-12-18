import 'package:flutter/material.dart';

class DisposalDetailScreen extends StatelessWidget {
  final String id;
  const DisposalDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Penghapusan')),
      body: Center(child: Text('Detail for ID: $id (Coming Soon)')),
    );
  }
}
