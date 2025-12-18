enum ReportType {
  inventory, // Laporan Inventaris (KIB)
  mutation, // Laporan Mutasi
  maintenance, // Laporan Pemeliharaan
  disposal, // Laporan Penghapusan
  summary, // Ringkasan Eksekutif
}

enum KibType {
  kibA, // Tanah
  kibB, // Peralatan & Mesin
  kibC, // Gedung & Bangunan
  kibD, // Jalan & Irigasi
  kibE, // Aset Lainnya
  kibF, // Konstruksi Dalam Pengerjaan
  all, // Gabungan
}

class ReportFilter {
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? departmentId; // Unit Kerja
  final String? categoryId;
  final KibType? kibType; // Only for inventory reports
  final bool includeZeroValue; // Tampilkan aset nilai 0?

  ReportFilter({
    required this.type,
    required this.startDate,
    required this.endDate,
    this.departmentId,
    this.categoryId,
    this.kibType,
    this.includeZeroValue = false,
  });

  // Default filter (This Month)
  factory ReportFilter.defaults() {
    final now = DateTime.now();
    return ReportFilter(
      type: ReportType.inventory,
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'department_id': departmentId,
      'category_id': categoryId,
      'kib_type': kibType?.name,
      'include_zero_value': includeZeroValue,
    };
  }

  ReportFilter copyWith({
    ReportType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? departmentId,
    String? categoryId,
    KibType? kibType,
    bool? includeZeroValue,
  }) {
    return ReportFilter(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      departmentId: departmentId ?? this.departmentId,
      categoryId: categoryId ?? this.categoryId,
      kibType: kibType ?? this.kibType,
      includeZeroValue: includeZeroValue ?? this.includeZeroValue,
    );
  }
}
