import 'item.dart';

class RequestModel {
  final String id;
  final String userId;
  List<ItemModel> items;
  String status;
  final String? reassignedFrom;
  final String? assignedTo; // ✅ add this
  final String? createdAt; // ✅ add this

  RequestModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    this.reassignedFrom,
    this.assignedTo,
    this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List).map((i) => ItemModel.fromJson(i)).toList(),
      status: json['status'] ?? 'Pending',
      reassignedFrom: json['reassignedFrom'],
      assignedTo: json['assignedTo'], // ✅ safe parse
      createdAt: json['createdAt'], // ✅ safe parse
    );
  }
}
