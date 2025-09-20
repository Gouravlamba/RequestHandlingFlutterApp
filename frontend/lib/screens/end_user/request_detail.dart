import 'package:flutter/material.dart';
import '../../models/request.dart';

class RequestDetailScreen extends StatelessWidget {
  final RequestModel request;
  const RequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("📌 Request ID: ${request.id}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          Text("Status: ${request.status}",
              style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 16),
          const Text("Items:",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: request.items.length,
              itemBuilder: (_, i) {
                final it = request.items[i];
                return Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading:
                        const Icon(Icons.shopping_cart, color: Colors.blue),
                    title: Text(it.name),
                    subtitle: Text(it.status),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
