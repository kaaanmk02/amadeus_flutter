/// `MemoryData.java` karşılığı.
class MemoryData {
  MemoryData({
    required this.id,
    required this.content,
    required this.timestamp,
    this.importance = 0.5,
  });

  final String id;
  final String content;
  final DateTime timestamp;
  final double importance;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'importance': importance,
      };

  factory MemoryData.fromJson(Map<String, dynamic> json) => MemoryData(
        id: json['id'] as String,
        content: json['content'] as String,
        timestamp: DateTime.tryParse(json['timestamp'] as String) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
      );
}
