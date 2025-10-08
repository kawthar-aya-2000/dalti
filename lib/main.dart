/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'onboarding_page.dart';
import 'login_page.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تهيئة Firebase
  runApp(const DaltiApp());
}

class DaltiApp extends StatefulWidget {
  const DaltiApp({super.key});

  @override
  State<DaltiApp> createState() => _DaltiAppState();
}

class _DaltiAppState extends State<DaltiApp> {
  bool _seenOnBoarding = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  Future<void> _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? alreadySeen = prefs.getBool('seenOnBoarding');

    setState(() {
      _seenOnBoarding = alreadySeen ?? false;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Dalti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      home: _seenOnBoarding ? const AuthWrapper() : const OnBoardingPage(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // 👉 يعمم RTL على التطبيق كامل
          child: child!,
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ الحالة: مازال Firebase يتحقق
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ المستخدم راهو مسجل دخول
        if (snapshot.hasData) {
          return const HomePage();
        }

        // ❌ ما كاش مستخدم → نعرض login page
        return const Scaffold(body: Center(child: LoginPage()));
      },
    );
  }
}*/

 //الاشعارات 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🟢 إضافة حزمة الإشعارات المحلية
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'onboarding_page.dart';
import 'login_page.dart';
import 'home_page.dart';

// 🟢 تعريف المتغير العام للإشعارات
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 تهيئة Firebase
  await Firebase.initializeApp();

  // 🟢 تهيئة إعدادات الإشعارات
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 🟢 طلب إذن الإشعارات (خاص بـ Android 13 وما فوق)
  final androidImplementation =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

try {
  await androidImplementation?.requestNotificationsPermission();
} catch (e) {
  print("⚠️ إذن الإشعارات غير متوفر على هذا النظام أو الإصدار");
}


  // 🟢 تشغيل التطبيق
  runApp(const DaltiApp());
}


class DaltiApp extends StatefulWidget {
  const DaltiApp({super.key});

  @override
  State<DaltiApp> createState() => _DaltiAppState();
}

class _DaltiAppState extends State<DaltiApp> {
  bool _seenOnBoarding = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  Future<void> _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? alreadySeen = prefs.getBool('seenOnBoarding');

    setState(() {
      _seenOnBoarding = alreadySeen ?? false;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Dalti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      home: _seenOnBoarding ? const AuthWrapper() : const OnBoardingPage(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // 👉 يعمم RTL على التطبيق كامل
          child: child!,
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ الحالة: مازال Firebase يتحقق
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ المستخدم راهو مسجل دخول
        if (snapshot.hasData) {
          return const HomePage();
        }

        // ❌ ما كاش مستخدم → نعرض login page
        return const Scaffold(body: Center(child: LoginPage()));
      },
    );
  }
}
