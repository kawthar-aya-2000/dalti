/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ اختيار حساب Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // المستخدم لغى العملية
      }

      // 2️⃣ جلب التوكينات
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ إنشاء Credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4️⃣ تسجيل الدخول في Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم تسجيل الدخول بـ Google")),
        );

        // 👉 توجيه المستخدم للـ HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ خطأ: $e")),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل الدخول")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text("تسجيل الدخول بـ Google"),
              ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // ✅ للتحقق من الانترنت
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // ✅ تحقق من الاتصال بالإنترنت قبل تسجيل الدخول
      bool isConnected = await _checkInternetConnection();
      if (!isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⚠️ انت غير متصل بشبكة الانترنت"),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // 1️⃣ اختيار حساب Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return; // المستخدم لغى العملية
      }

      // 2️⃣ جلب التوكينات
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ إنشاء Credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4️⃣ تسجيل الدخول في Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم تسجيل الدخول بـ Google")),
        );

        // 👉 توجيه المستخدم للـ HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = "❌ خطأ غير معروف، حاول مرة أخرى";

        // إذا كان الخطأ بسبب الإنترنت
        if (e.toString().contains("network_error") ||
            e.toString().contains("ApiException: 7")) {
          errorMessage = "⚠️ لا يوجد اتصال بالإنترنت";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل الدخول")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text("تسجيل الدخول بـ Google"),
              ),
      ),
    );
  }
}
