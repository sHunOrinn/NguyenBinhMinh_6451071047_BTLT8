class Enrollment {
  final int? id;
  final int studentId;
  final int courseId;

  Enrollment({this.id, required this.studentId, required this.courseId});

  Map<String, dynamic> toMap() =>
      {'id': id, 'studentId': studentId, 'courseId': courseId};

  factory Enrollment.fromMap(Map<String, dynamic> m) => Enrollment(
    id: m['id'],
    studentId: m['studentId'],
    courseId: m['courseId'],
  );
}