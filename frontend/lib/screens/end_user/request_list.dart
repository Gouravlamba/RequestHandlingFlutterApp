import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import 'create_request.dart';
import 'request_detail.dart';

class EndUserRequestListScreen extends ConsumerStatefulWidget {
  const EndUserRequestListScreen({super.key});

  @override
  ConsumerState<EndUserRequestListScreen> createState() =>
      _EndUserRequestListScreenState();
}

class _EndUserRequestListScreenState
    extends ConsumerState<EndUserRequestListScreen> {
  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    ref
        .read(requestProvider.notifier)
        .start(role: 'end_user', userId: auth.userId);
  }

  @override
  void dispose() {
    ref.read(requestProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reqState = ref.watch(requestProvider);
    final auth = ref.watch(authProvider);

    final myRequests =
        reqState.requests.where((r) => r.userId == auth.userId).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: reqState.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: myRequests.length,
              itemBuilder: (_, i) {
                final r = myRequests[i];
                return Card(
                  color: Colors.blue.shade50,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('Request ${r.id.substring(0, 6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${r.items.length} items — ${r.status}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // delete future
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RequestDetailScreen(request: r)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
