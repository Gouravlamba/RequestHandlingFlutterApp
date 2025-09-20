import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';

class ConfirmRequestScreen extends ConsumerStatefulWidget {
  final RequestModel request;
  const ConfirmRequestScreen({super.key, required this.request});

  @override
  ConsumerState<ConfirmRequestScreen> createState() =>
      _ConfirmRequestScreenState();
}

class _ConfirmRequestScreenState extends ConsumerState<ConfirmRequestScreen> {
  final Map<String, bool> _choices = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    for (var it in widget.request.items) {
      _choices[it.id] = it.status == "Available";
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final confirmations = _choices.entries
          .map((e) => {"itemId": e.key, "available": e.value})
          .toList();

      final auth = ref.read(authProvider);
      await ref.read(requestProvider.notifier).confirmRequest(
            widget.request.id,
            confirmations,
            auth.userId!,
          );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confirm Request ${req.id.substring(0, 6)}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${req.status}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Items',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: req.items.length,
                itemBuilder: (_, i) {
                  final it = req.items[i];
                  return CheckboxListTile(
                    activeColor: Colors.blue,
                    value: _choices[it.id] ?? false,
                    onChanged: (v) =>
                        setState(() => _choices[it.id] = v ?? false),
                    title: Text(it.name),
                    subtitle: Text('Current: ${it.status}'),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Confirmation',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
