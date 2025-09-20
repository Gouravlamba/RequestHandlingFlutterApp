import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/request_provider.dart';
import 'confirm_request.dart';

class ReceiverRequestListScreen extends ConsumerStatefulWidget {
  const ReceiverRequestListScreen({super.key});

  @override
  ConsumerState<ReceiverRequestListScreen> createState() =>
      _ReceiverRequestListScreenState();
}

class _ReceiverRequestListScreenState
    extends ConsumerState<ReceiverRequestListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(requestProvider.notifier).start(role: 'receiver');
    });
  }

  @override
  void dispose() {
    ref.read(requestProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reqState = ref.watch(requestProvider);
    final items = reqState.requests;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (_) {
          if (reqState.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (reqState.error != null) {
            return Center(
              child: Text(
                '⚠️ Error: ${reqState.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "No requests assigned yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final r = items[i];
              return Card(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    'Request ${r.id.substring(0, 6)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    '${r.items.length} items — ${r.status}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConfirmRequestScreen(request: r),
                        ),
                      );
                    },
                    child: const Text("Confirm"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
