import 'package:flutter/material.dart';

enum DisposalStatus {
  draft,
  submitted,
  valued, // Sudah dinilai harganya
  approved, // Disetujui untuk dihapus
  auctioned, // Dilelang (jika ada)
  completed; // Selesai dihapus dari aset

  String get displayName {
    switch (this) {
      case DisposalStatus.draft:
        return 'Draft';
      case DisposalStatus.submitted:
        return 'Diajukan';
      case DisposalStatus.valued:
        return 'Dinilai';
      case DisposalStatus.approved:
        return 'Disetujui';
      case DisposalStatus.auctioned:
        return 'Dilelang';
      case DisposalStatus.completed:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case DisposalStatus.draft:
        return Colors.grey;
      case DisposalStatus.submitted:
        return Colors.blue;
      case DisposalStatus.valued:
        return Colors.purple;
      case DisposalStatus.approved:
        return Colors.orange;
      case DisposalStatus.auctioned:
        return Colors.indigo;
      case DisposalStatus.completed:
        return Colors.red;
    }
  }
}

class DisposalRequest {
  final String id;
  final String assetId;
  final String assetName; // Joined
  final String assetQrCode;
  final String reason; // Rusak Berat, Hilang, Usang
  final String description;
  final DisposalStatus status;
  final double? estimatedValue; // Nilai Limit / Taksiran
  final double? finalSalePrice; // Nilai Jual (jika dilelang)
  final String? createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DisposalRequest({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.assetQrCode,
    required this.reason,
    required this.description,
    required this.status,
    this.estimatedValue,
    this.finalSalePrice,
    this.createdBy,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory/Map methods would go here similar to other models
}

