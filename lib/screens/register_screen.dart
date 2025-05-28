import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../provider/globalProvider.dart';
import '../models/user_model.dart';
import 'login_page.dart';
import 'home_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  bool isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> register() async {
    setState(() => isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
      _showError('Бүх талбарыг бөглөнө үү');
      setState(() => isLoading = false);
      return;
    }

    if (password != repeatPassword) {
      _showError('Нууц үг таарахгүй байна');
      setState(() => isLoading = false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        _showError('Бүртгэл амжилтгүй боллоо');
        return;
      }

      await user.updateDisplayName(email.split('@')[0]);

      final userModel = UserModel(
        id: user.uid.hashCode,
        email: user.email,
        name: Name(
          firstname: user.displayName ?? user.email!.split('@')[0],
          lastname: '',
        ),
        address: Address(city: 'N/A', street: 'N/A', number: 0, zipcode: 'N/A'),
        phone: 'N/A',
      );

      final global = Provider.of<GlobalProvider>(context, listen: false);
      global.setCurrentUser(userModel);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      _showError('Бүртгэх үед алдаа гарлаа: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Бүртгүүлэх')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Бүртгүүлэх 👤',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'И-мэйл',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Нууц үг',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: repeatPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Нууц үгээ давтан оруулна уу',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: register,
                    child: const Text('Бүртгүүлэх'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Бүртгэлтэй юу? Нэвтрэх'),
            ),
          ],
        ),
      ),
    );
  }
}
