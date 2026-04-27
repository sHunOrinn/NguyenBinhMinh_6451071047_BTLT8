class Item {
  final int? id;
  final String name;
  final String description;

  Item({this.id, required this.name, required this.description});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory Item.fromMap(Map<String, dynamic> m) => Item(
    id: m['id'],
    name: m['name'],
    description: m['description'],
  );
}