import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:shop_app_ex/repository/repository.dart';
import 'package:shop_app_ex/screens/home_page.dart';
import 'package:shop_app_ex/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> moveToHome(BuildContext context) async {
    setState(() => isLoading = true);

    final email = userNameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
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
        _showError('Login failed. Please try again.');
        return;
      }

      final global = Provider.of<GlobalProvider>(context, listen: false);
      // Mock user data since fakestoreapi.com doesn't align with Firebase UIDs
      final userModel = UserModel(
        id: int.parse(user.uid.hashCode.toString()),
        email: user.email,
        name: Name(
          firstname: user.displayName?.split(' ')[0] ?? 'User',
          lastname: '',
        ),
        phone: 'N/A',
        address: Address(city: 'N/A', street: 'N/A', number: 0, zipcode: 'N/A'),
      );
      global.setCurrentUser(userModel);

      await Provider.of<MyRepository>(
        context,
        listen: false,
      ).fetchCartProductsAndSetToProvider(context, userModel.id.toString());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        default:
          message = 'Login error: ${e.message}';
      }
      _showError(message);
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> register(BuildContext context) async {
    setState(() => isLoading = true);

    final email = userNameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      setState(() => isLoading = false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        _showError('Registration failed. Please try again.');
        return;
      }

      await user.updateDisplayName(email.split('@')[0]);

      final global = Provider.of<GlobalProvider>(context, listen: false);
      final userModel = UserModel(
        id: int.parse(user.uid.hashCode.toString()),
        email: user.email,
        name: Name(firstname: user.displayName ?? 'User', lastname: ''),
        phone: 'N/A',
        address: Address(city: 'N/A', street: 'N/A', number: 0, zipcode: 'N/A'),
      );
      global.setCurrentUser(userModel);

      await Provider.of<MyRepository>(
        context,
        listen: false,
      ).fetchCartProductsAndSetToProvider(context, userModel.id.toString());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email is already in use.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        default:
          message = 'Registration error: ${e.message}';
      }
      _showError(message);
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Нэвтрэх'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Тавтай морил 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Нэвтрэх эсвэл бүртгүүлнэ үү',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(
                labelText: 'И-мэйл',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
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
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => moveToHome(context),
                          icon: const Icon(Icons.login),
                          label: const Text('Нэвтрэх'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => register(context),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Бүртгүүлэх'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () async {
                  final email = userNameController.text.trim();
                  if (email.isEmpty) {
                    _showError('Please enter your email to reset password');
                    return;
                  }
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );
                    _showError('Password reset email sent');
                  } catch (e) {
                    _showError('Error sending password reset email: $e');
                  }
                },
                child: const Text('Нууц үгээ мартсан уу?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
