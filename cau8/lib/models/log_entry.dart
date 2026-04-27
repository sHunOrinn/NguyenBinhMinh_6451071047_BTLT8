class LogEntry {
  final int? id;
  final String action;
  final String time;

  LogEntry({
    this.id,
    required this.action,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'action': action,
    'time': time,
  };

  factory LogEntry.fromMap(Map<String, dynamic> m) => LogEntry(
    id: m['id'],
    action: m['action'],
    time: m['time'],
  );

  /// Format hiển thị trong file log
  String toLogLine() => '[${time}] ${action}';
}