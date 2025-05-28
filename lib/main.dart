import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_ex/repository/repository.dart';
import 'package:shop_app_ex/services/httpservices.dart';
import 'package:shop_app_ex/screens/home_page.dart';
import 'package:shop_app_ex/provider/globalProvider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('lang') ?? 'en';

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('mn', 'MN')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: langCode == 'mn'
          ? const Locale('mn', 'MN')
          : const Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GlobalProvider()),
          Provider(
            create: (_) => HttpService(baseUrl: 'https://fakestoreapi.com'),
          ),
          ProxyProvider<HttpService, MyRepository>(
            update: (_, httpService, __) =>
                MyRepository(httpService: httpService),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(useMaterial3: false),
      home: const HomePage(),
    );
  }
}
