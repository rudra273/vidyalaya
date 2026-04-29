class TimeSlot {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final bool isBreak;

  const TimeSlot({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isBreak = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'isBreak': isBreak,
    };
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isBreak: json['isBreak'] as bool? ?? false,
    );
  }

  TimeSlot copyWith({
    String? id,
    String? name,
    String? startTime,
    String? endTime,
    bool? isBreak,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBreak: isBreak ?? this.isBreak,
    );
  }
}
