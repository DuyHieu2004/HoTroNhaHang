// File: PhieuTamUng.dart
class PhieuTamUng{
  String? ma; // This will be the document ID
  String? maDonDatCho; // Link to DonDatCho
  double? soTien; // Changed to double
  DateTime? ngayLap;

  PhieuTamUng({
    this.ma,
    this.maDonDatCho, // Added to constructor
    this.soTien,
    this.ngayLap,
  });

  Map<String, dynamic> toMap() {
    return {
      'ma': ma,
      'maDonDatCho': maDonDatCho, // To Firestore
      'soTien': soTien,
      'ngayLap': ngayLap?.toIso8601String(),
    };
  }

  factory PhieuTamUng.fromMap(Map<String, dynamic> map) {
    return PhieuTamUng(
      ma: map['ma'],
      maDonDatCho: map['maDonDatCho'], // From Firestore
      soTien: (map['soTien'] as num?)?.toDouble(), // Cast to double
      ngayLap: DateTime.tryParse(map['ngayLap'] ?? ''),
    );
  }
}