import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class QrScan extends Equatable {
  final String id;
  final String playerId;
  final String businessId;
  final String businessName;
  final int pointsEarned;
  final DateTime scannedAt;
  final String? notes;

  const QrScan({
    required this.id,
    required this.playerId,
    required this.businessId,
    required this.businessName,
    required this.pointsEarned,
    required this.scannedAt,
    this.notes,
  });

  factory QrScan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Handle scannedAt robustly
    DateTime scannedAtDate;
    final dynamic rawScannedAt =
        data['scannedAt'] ?? data['scanned_at'] ?? data['timestamp'];
    if (rawScannedAt is Timestamp) {
      scannedAtDate = rawScannedAt.toDate();
    } else if (rawScannedAt is String) {
      scannedAtDate = DateTime.tryParse(rawScannedAt) ?? DateTime.now();
    } else {
      scannedAtDate = DateTime.now();
    }

    // Handle pointsEarned robustly
    int points;
    final dynamic rawPoints =
        data['pointsEarned'] ??
        data['points_awarded'] ??
        data['points_earned'] ??
        0;
    if (rawPoints is int) {
      points = rawPoints;
    } else if (rawPoints is double) {
      points = rawPoints.toInt();
    } else if (rawPoints is String) {
      points = int.tryParse(rawPoints) ?? 0;
    } else {
      points = 0;
    }

    return QrScan(
      id: doc.id,
      playerId: (data['playerId'] ?? data['player_id'] ?? data['user_id'] ?? '')
          .toString(),
      businessId: (data['businessId'] ?? data['business_id'] ?? '').toString(),
      businessName:
          (data['businessName'] ?? data['business_name'] ?? 'Unknown Business')
              .toString(),
      pointsEarned: points,
      scannedAt: scannedAtDate,
      notes: data['notes']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'businessId': businessId,
      'businessName': businessName,
      'pointsEarned': pointsEarned,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'notes': notes,
    };
  }

  QrScan copyWith({
    String? id,
    String? playerId,
    String? businessId,
    String? businessName,
    int? pointsEarned,
    DateTime? scannedAt,
    String? notes,
  }) {
    return QrScan(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      scannedAt: scannedAt ?? this.scannedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    playerId,
    businessId,
    businessName,
    pointsEarned,
    scannedAt,
    notes,
  ];
}
