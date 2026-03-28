class ReviewData {
  final String itemId;
  final double easeFactor;
  final int intervalDays;
  final int nextReview; // Unix epoch in seconds
  final int repetitions;
  final int lastQuality;

  const ReviewData({
    required this.itemId,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.nextReview = 0,
    this.repetitions = 0,
    this.lastQuality = 0,
  });

  ReviewData copyWith({
    String? itemId,
    double? easeFactor,
    int? intervalDays,
    int? nextReview,
    int? repetitions,
    int? lastQuality,
  }) {
    return ReviewData(
      itemId: itemId ?? this.itemId,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReview: nextReview ?? this.nextReview,
      repetitions: repetitions ?? this.repetitions,
      lastQuality: lastQuality ?? this.lastQuality,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'ease_factor': easeFactor,
      'interval_days': intervalDays,
      'next_review': nextReview,
      'repetitions': repetitions,
      'last_quality': lastQuality,
    };
  }

  factory ReviewData.fromMap(Map<String, dynamic> map) {
    return ReviewData(
      itemId: map['item_id'] as String,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (map['interval_days'] as num?)?.toInt() ?? 0,
      nextReview: (map['next_review'] as num?)?.toInt() ?? 0,
      repetitions: (map['repetitions'] as num?)?.toInt() ?? 0,
      lastQuality: (map['last_quality'] as num?)?.toInt() ?? 0,
    );
  }
}
