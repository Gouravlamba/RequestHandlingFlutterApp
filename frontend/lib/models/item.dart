class ItemModel {
  final String id;
  final String name;
  String status; // Pending / Available / Not Available

  ItemModel({required this.id, required this.name, required this.status});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'status': status};
}
