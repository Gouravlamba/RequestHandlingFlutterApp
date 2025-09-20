import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../end_user/user_profile.dart';
import '../receiver/receiver_profile.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  String _role = 'user';
  String _gender = 'male';
  bool _loading = false;

  void _login() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter username')));
      return;
    }

    setState(() => _loading = true);
    await ref
        .read(authProvider.notifier)
        .login(username, _role, gender: _gender);
    final auth = ref.read(authProvider);
    setState(() => _loading = false);

    if (auth.userId != null) {
      if (auth.role == 'user') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ReceiverProfileScreen()),
          (route) => false,
        );
      }
    } else {
      final err = ref.read(authProvider).error ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Welcome to Our App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Role dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Login as', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _role,
                    dropdownColor: Colors.blue[700],
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: 'user',
                          child: Text('User',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 'receiver',
                          child: Text('Receiver',
                              style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? 'user'),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Gender dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wc, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Gender', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _gender,
                    dropdownColor: Colors.blue[700],
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: 'male',
                          child: Text('Male',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 'female',
                          child: Text('Female',
                              style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? 'male'),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Username input
            SizedBox(
              width: 280,
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Login button
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
