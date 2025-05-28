import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../provider/globalProvider.dart';
import '../models/user_model.dart';
import 'register_screen.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> login() async {
    setState(() => isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('И-мэйл болон нууц үг хоёуланг оруулна уу');
      setState(() => isLoading = false);
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Нэвтрэхэд алдаа гарлаа');
        return;
      }

      final userModel = UserModel(
        id: user.uid.hashCode,
        email: user.email,
        name: Name(firstname: user.displayName ?? 'User', lastname: ''),
        address: Address(city: 'N/A', street: 'N/A', number: 0, zipcode: 'N/A'),
        phone: 'N/A',
      );

      Provider.of<GlobalProvider>(
        context,
        listen: false,
      ).setCurrentUser(userModel);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Алдаа гарлаа';
      if (e.code == 'user-not-found') {
        message = 'Хэрэглэгч олдсонгүй';
      } else if (e.code == 'wrong-password') {
        message = 'Нууц үг буруу байна';
      }
      _showError(message);
    } catch (e) {
      _showError('Нэвтрэх үед алдаа гарлаа: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showError('Нууц үг сэргээхийн тулд и-мэйл хаяг оруулна уу');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showError('Нууц үг сэргээх имэйл илгээгдлээ');
    } catch (e) {
      _showError('Алдаа гарлаа: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Нэвтрэх')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Нэвтрэх 👋',
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
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: login,
                        child: const Text('Нэвтрэх'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: resetPassword,
                        child: const Text('Нууц үгээ мартсан уу?'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Шинэ хэрэглэгч үү? Бүртгүүлэх'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
