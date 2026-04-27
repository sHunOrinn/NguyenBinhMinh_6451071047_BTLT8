class Student {
  final int? id;
  final String name;

  Student({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Student.fromMap(Map<String, dynamic> m) =>
      Student(id: m['id'], name: m['name']);
}