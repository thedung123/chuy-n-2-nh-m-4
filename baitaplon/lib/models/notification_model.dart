class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  // Sau này dùng để nhận dữ liệu từ API PHP
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'Thông báo',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['created_at']),
      isRead: json['is_read'] == 1,
    );
  }
}
