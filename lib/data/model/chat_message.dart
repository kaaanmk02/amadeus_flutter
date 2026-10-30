/// `ChatMessage.java` karşılığı.
class ChatMessage {
  ChatMessage({
    required this.role,
    required this.content,
    this.imageBase64,
    this.imageList,
    this.timestamp,
    this.emotion,
    this.emotionIntensity,
  });

  final String role; // 'system' | 'user' | 'assistant'
  final String content;
  final String? imageBase64;
  final List<String>? imageList;
  final DateTime? timestamp;
  final String? emotion;
  final double? emotionIntensity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'role': role,
        'content': content,
        if (imageBase64 != null) 'imageBase64': imageBase64,
        if (imageList != null) 'imageList': imageList,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
        if (emotion != null) 'emotion': emotion,
        if (emotionIntensity != null) 'emotionIntensity': emotionIntensity,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        imageBase64: json['imageBase64'] as String?,
        imageList: (json['imageList'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        timestamp: json['timestamp'] == null
            ? null
            : DateTime.tryParse(json['timestamp'] as String),
        emotion: json['emotion'] as String?,
        emotionIntensity: (json['emotionIntensity'] as num?)?.toDouble(),
      );
}
