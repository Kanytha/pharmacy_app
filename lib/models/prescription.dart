// Add at the very top after imports
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

class Prescription {
  final int prescriptionId;
  final int userId;
  final String prescriptionNumber;
  final String imagePath;
  final String? doctorName;
  final String uploadDate;
  final String verificationStatus;
  final int? verifiedBy;
  final String? verifiedAt;
  final String? notes;

  Prescription({
    required this.prescriptionId,
    required this.userId,
    required this.prescriptionNumber,
    required this.imagePath,
    this.doctorName,
    required this.uploadDate,
    required this.verificationStatus,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      prescriptionId: int.parse(json['prescription_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      prescriptionNumber: json['prescription_number'],
      imagePath: json['image_path'],
      doctorName: json['doctor_name'],
      uploadDate: json['upload_date'],
      verificationStatus: json['verification_status'],
      verifiedBy: json['verified_by'] != null
          ? int.parse(json['verified_by'].toString())
          : null,
      verifiedAt: json['verified_at'],
      notes: json['notes'],
    );
  }

  String get statusDisplay {
    switch (verificationStatus) {
      case 'pending':
        return 'Pending Verification';
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      default:
        return verificationStatus;
    }
  }
}