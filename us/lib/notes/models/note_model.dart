class Note {
  final String id;
  final String userId;
  final String content;
  final DateTime selectedDate;
  final List<String> imageUrls;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.userId,
    required this.content,
    required this.selectedDate,
    required this.imageUrls,
    required this.createdAt,
  });

  // Factory constructor to create a Note from Supabase JSON data
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      selectedDate: json['selected_date'] != null
          ? DateTime.parse(json['selected_date'])
          : DateTime.now(),
      // Supabase returns arrays as List<dynamic>, so we cast to List<String>
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  // Convert Note to JSON for sending to Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content': content,
      'selected_date': selectedDate.toIso8601String(),
      'image_urls': imageUrls,
      // 'created_at' is handled by default in Supabase
    };
  }
}
