class Course {
  final int? id;
  final String name;

  Course({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Course.fromMap(Map<String, dynamic> m) =>
      Course(id: m['id'], name: m['name']);
}