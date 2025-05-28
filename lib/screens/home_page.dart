import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:shop_app_ex/screens/bags_page.dart';
import 'package:shop_app_ex/screens/shop_page.dart';
import 'package:shop_app_ex/screens/favorite_page.dart';
import 'package:shop_app_ex/screens/profile_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification.body ?? 'New notification received!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Handle notification tap, e.g., navigate to a specific screen
              },
            ),
          ),
        );
      }
    });

    // Background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap when app is opened from background
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'App opened from notification: ${message.notification?.title}',
          ),
        ),
      );
    });

    // Get FCM token for testing
    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint('FCM Token: $token');
    });
  }

  final List<Widget> pages = [
    const ShopPage(),
    const BagsPage(),
    const FavoritePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: pages[provider.currentIdx],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: provider.currentIdx,
            onTap: provider.changeCurrentIdx,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.shop),
                label: 'shop'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_basket),
                label: 'card'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite),
                label: 'favorites'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: 'profile'.tr(),
              ),
            ],
          ),
        );
      },
    );
  }
}
