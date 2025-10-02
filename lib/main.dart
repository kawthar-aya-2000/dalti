import 'package:flutter/material.dart';
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
}
/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'onboarding_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'booking_confirmation_page.dart';

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

  Future<Widget> _checkUserAppointment(User user) async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  print("🔍 Checking appointments for ${user.uid}");

  final snapshot = await FirebaseFirestore.instance
      .collection("appointments")
      .where("patientId", isEqualTo: user.uid)
      .where("status", isEqualTo: "pending")
      .where("createdAt", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where("createdAt", isLessThan: Timestamp.fromDate(endOfDay))
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    final data = snapshot.docs.first.data();

    print("✅ Appointment found: ${data["clinicName"]}, queue ${data["queueNumber"]}");

    return BookingConfirmationPage(
      clinicName: data["clinicName"] ?? "عيادة",
      doctorName: data["doctorName"] ?? "طبيب",
      patientName: "${data["patientName"]} ${data["patientLastName"]}",
      queueNumber: data["queueNumber"] ?? 0,
      clinicId: data["clinicId"],
    );
  } else {
    print("ℹ No appointment found → redirecting to HomePage");
    return const HomePage();
  }
}


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<Widget>(
            future: _checkUserAppointment(user),
            builder: (context, futureSnapshot) {
              if (!futureSnapshot.hasData) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return futureSnapshot.data!;
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}*/
