import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:shop_app_ex/screens/login_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_app_ex/screens/home_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> changeLanguage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (context.locale == const Locale('en', 'US')) {
      await prefs.setString('lang', 'mn');
      await context.setLocale(const Locale('mn', 'MN'));
    } else {
      await prefs.setString('lang', 'en');
      await context.setLocale(const Locale('en', 'US'));
    }
    // UI-г шууд шинэчлэх
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        return Scaffold(
          appBar: AppBar(title: const Text('Миний профайл')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                      'https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.name?.lastname ?? ''} ${user?.name?.firstname ?? ''}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? 'И-мэйл байхгүй',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 40),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: Text(user?.phone ?? 'Утасны дугаар байхгүй'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: Text(
                  '${user?.address?.city ?? ''}, ${user?.address?.street ?? ''} ${user?.address?.number ?? ''}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: Text('Төлбөрийн хэрэгсэл'.tr()),
                onTap: () {
                  debugPrint('[ACTION] Төлбөрийн хэрэгсэл дээр дарлаа');
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.purple),
                title: Text('Хэл солих'.tr()),
                onTap: () => changeLanguage(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text('Гарах'.tr()),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  provider.setCurrentUser(null);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
