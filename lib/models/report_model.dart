class Report {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String status;
  final String? imageUrl; // Opsional, jika ada foto
  final String? description; // Opsional, deskripsi detail masalah

  Report({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    this.imageUrl,
    this.description,
  });
}