class Business {
  final String id;
  final String name;
  final String category;
  final String? heroImageUrl;
  final String? address;
  final String? street;
  final String? city;
  final String? state;
  final String? zip;
  final String? phoneNumber;
  final String? website;
  final double latitude;
  final double longitude;
  final String? pitch;
  final Promotion? promotion;
  final LoyaltyProgram? loyaltyProgram;
  final Map<String, String>? hours;
  final String? menuUrl;
  final String? secretCode;
  final int? checkInPoints;

  Business({
    required this.id,
    required this.name,
    required this.category,
    this.heroImageUrl,
    this.address,
    this.street,
    this.city,
    this.state,
    this.zip,
    this.phoneNumber,
    this.website,
    required this.latitude,
    required this.longitude,
    this.pitch,
    this.promotion,
    this.loyaltyProgram,
    this.hours,
    this.menuUrl,
    this.secretCode,
    this.checkInPoints,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Business',
      category: json['category'] as String? ?? 'General',
      heroImageUrl: json['heroImageUrl'] as String?,
      address: json['address'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zip: json['zip'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      pitch: json['pitch'] as String?,
      promotion: json['promotion'] != null && json['promotion'] is Map
          ? Promotion.fromJson(Map<String, dynamic>.from(json['promotion']))
          : null,
      loyaltyProgram:
          json['loyaltyProgram'] != null && json['loyaltyProgram'] is Map
          ? LoyaltyProgram.fromJson(
              Map<String, dynamic>.from(json['loyaltyProgram']),
            )
          : null,
      hours: json['hours'] != null
          ? Map<String, String>.from(json['hours'])
          : null,
      menuUrl: json['menuUrl'] as String?,
      secretCode: json['secretCode'] as String? ?? 'SECRET',
      checkInPoints: _parseInt(json['checkInPoints']) ?? 100,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get fullAddress {
    if (street != null && city != null && state != null) {
      return '$street, $city, $state $zip';
    }
    return address ?? 'Address not available';
  }

  String get location {
    if (city != null && state != null) {
      return '$city, $state';
    }
    // Fallback: try to extract City, State from the address field
    if (address != null && address!.isNotEmpty) {
      final parts = address!.split(',');
      if (parts.length >= 3) {
        // e.g. "123 Main St, Bellevue, NE 68005" -> "Bellevue, NE"
        final cityPart = parts[1].trim();
        final stateZipPart = parts[2].trim();
        final statePart = stateZipPart.split(' ').first;
        return '$cityPart, $statePart';
      } else if (parts.length == 2) {
        // e.g. "Bellevue, NE"
        return address!.trim();
      }
    }
    return '';
  }

  bool get hasReward => promotion != null;

  int get points => checkInPoints ?? 0;
}

class Promotion {
  final String title;
  final String description;
  final String code;

  Promotion({
    required this.title,
    required this.description,
    required this.code,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      title: json['title'] as String? ?? 'Special Offer',
      description: json['description'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class LoyaltyProgram {
  final int totalCheckInsRequired;
  final int currentCheckIns;

  LoyaltyProgram({
    required this.totalCheckInsRequired,
    required this.currentCheckIns,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      totalCheckInsRequired: json['totalCheckInsRequired'] as int? ?? 10,
      currentCheckIns: json['currentCheckIns'] as int? ?? 0,
    );
  }
}
