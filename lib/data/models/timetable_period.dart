class TimetablePeriod {
  final String id;
  final String subject;
  final String startTime;
  final String endTime;

  const TimetablePeriod({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory TimetablePeriod.fromJson(Map<String, dynamic> json) {
    return TimetablePeriod(
      id: json['id'] as String,
      subject: json['subject'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  TimetablePeriod copyWith({
    String? id,
    String? subject,
    String? startTime,
    String? endTime,
  }) {
    return TimetablePeriod(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
