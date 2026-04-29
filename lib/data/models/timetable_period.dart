class TimetablePeriod {
  final String id;
  final String subject;
  final String startTime;
  final String endTime;
  final String? slotId;

  const TimetablePeriod({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.slotId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'startTime': startTime,
      'endTime': endTime,
      if (slotId != null) 'slotId': slotId,
    };
  }

  factory TimetablePeriod.fromJson(Map<String, dynamic> json) {
    return TimetablePeriod(
      id: json['id'] as String,
      subject: json['subject'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      slotId: json['slotId'] as String?,
    );
  }

  TimetablePeriod copyWith({
    String? id,
    String? subject,
    String? startTime,
    String? endTime,
    String? slotId,
  }) {
    return TimetablePeriod(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotId: slotId ?? this.slotId,
    );
  }
}
