/*// الاشعاارت
import 'package:dalti/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// نجيب نفس المتغيّر اللي جهزناه في main.dart
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class BookingConfirmationPage extends StatefulWidget {
  final String clinicName;
  final String doctorName;
  final String patientName;
  final int queueNumber;
  final String clinicId;

  const BookingConfirmationPage({
    super.key,
    required this.clinicName,
    required this.doctorName,
    required this.patientName,
    required this.queueNumber,
    required this.clinicId,
  });

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  bool notified = false; // باش ما يعاودش الإشعار بزاف المرات

  /*Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'queue_channel',
          'إشعارات الدور',
          channelDescription: 'إشعار عندما يحين دورك في العيادة',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'دورك الآن!',
      'الطبيب ${widget.doctorName} جاهز لاستقبالك.',
      details,
    );
  }*/
  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'queue_channel',
          'إشعارات الدور',
          channelDescription: 'إشعار عندما يحين أو يقترب دورك في العيادة',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(0, title, body, details);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("تأكيد الحجز"),
            backgroundColor: Colors.teal,
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.clinicName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "الطبيب: ${widget.doctorName}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  "المريض: ${widget.patientName}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),

                const Text(
                  "رقم دورك هو:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.teal.shade100,
                  ),
                  child: Text(
                    "${widget.queueNumber}",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // بث مباشر للدور الحالي
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("clinics")
                      .doc(widget.clinicId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final clinicData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    final currentNumber =
                        clinicData?['booking']?['queue']?['currentNumber'] ?? 0;

                    // 🔔 إشعار عند وصول الدور
                    /*if (currentNumber == widget.queueNumber && !notified) {
                      notified = true;
                      _showNotification();
                    }*/
                    /*if (!notified) {
                      final int current = (currentNumber is int)
                          ? currentNumber
                          : (currentNumber is double)
                          ? currentNumber.toInt()
                          : int.tryParse(currentNumber.toString()) ?? 0;

                      if (current == widget.queueNumber) {
                        notified = true;
                        Future.delayed(
                          const Duration(milliseconds: 500),
                          _showNotification,
                        );
                      }
                    }*/

                    // 🔔 إشعار عند اقتراب الدور بدورين
                    if (widget.queueNumber > 2 &&
                        currentNumber == widget.queueNumber - 2 &&
                        !notified) {
                      notified = true;
                      _showNotification(
                        title: 'قرب دورك!',
                        body:
                            'باقي زوج دورات فقط ويجي دورك عند ${widget.doctorName} 🕒',
                      );
                    }

                    // 🔔 إشعار خاص باللي أرقامهم صغيرة (1 أو 2)
                    if (widget.queueNumber <= 2 &&
                        currentNumber == 0 &&
                        !notified) {
                      notified = true;
                      _showNotification(
                        title: 'قرب دورك!',
                        body: 'دورك قريب جدًا عند ${widget.doctorName} ⚡',
                      );
                    }

                    // 🔔 إشعار عند وصول الدور الحقيقي
                    if (currentNumber == widget.queueNumber) {
                      _showNotification(
                        title: 'دورك الآن!',
                        body:
                            'الطبيب ${widget.doctorName} جاهز لاستقبالك 👨‍⚕️',
                      );
                    }

                    return Text(
                      "الدور متوقف الآن عند الرقم: $currentNumber",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
import 'package:dalti/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

// إشعارات محلية
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class BookingConfirmationPage extends StatefulWidget {
  final String clinicName;
  final String doctorName;
  final String patientName;
  final int queueNumber;
  final String clinicId;

  const BookingConfirmationPage({
    super.key,
    required this.clinicName,
    required this.doctorName,
    required this.patientName,
    required this.queueNumber,
    required this.clinicId,
  });

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  bool notified = false;

  final Color primaryColor = const Color(0xFF006D77);
  final Color secondaryColor = const Color(0xFF83C5BE);
  final Color backgroundColor = const Color(0xFFEDF6F9);
  final Color accentColor = const Color(0xFFFFDDD2);

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'queue_channel',
      'إشعارات الدور',
      channelDescription: 'إشعار عندما يحين أو يقترب دورك في العيادة',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(0, title, body, details);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            // 🌊 AppBar متموج بخلفية مزدوجة
            ClipPath(
              clipper: WaveClipperTwo(flip: true),
              child: Container(
                height: 210,
                color: secondaryColor,
              ),
            ),
            ClipPath(
              clipper: WaveClipperOne(flip: true),
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48), // موازنة الأيقونة
                        const Text(
                          "تأكيد الحجز",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.home, color: Colors.white, size: 26),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const HomePage()),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 🌟 المحتوى (في الوسط)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 600),
              child: Align(
                alignment: Alignment.topCenter, // ⬅️ يوسّط أفقي فقط ويبقي المحتوى في الأعلى
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 230, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ✅ باش يتوسّط عموديًا
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🏥 معلومات العيادة
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: secondaryColor.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                widget.clinicName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "الطبيب: ${widget.doctorName}",
                                style: const TextStyle(fontSize: 17),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "المريض: ${widget.patientName}",
                                style: const TextStyle(fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "رقم دورك هو:",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 🔢 بطاقة رقم الدور
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 50),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          "${widget.queueNumber}",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 🩺 بث مباشر للدور الحالي
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("clinics")
                            .doc(widget.clinicId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final clinicData =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          final currentNumber =
                              clinicData?['booking']?['queue']?['currentNumber'] ?? 0;

                          // 🔔 إشعارات
                          if (widget.queueNumber > 2 &&
                              currentNumber == widget.queueNumber - 2 &&
                              !notified) {
                            notified = true;
                            _showNotification(
                              title: 'قرب دورك!',
                              body:
                                  'باقي زوج دورات فقط ويجي دورك عند ${widget.doctorName} 🕒',
                            );
                          }

                          if (widget.queueNumber <= 2 &&
                              currentNumber == 0 &&
                              !notified) {
                            notified = true;
                            _showNotification(
                              title: 'قرب دورك!',
                              body: 'دورك قريب جدًا عند ${widget.doctorName} ⚡',
                            );
                          }

                          if (currentNumber == widget.queueNumber) {
                            _showNotification(
                              title: 'دورك الآن!',
                              body:
                                  'الطبيب ${widget.doctorName} جاهز لاستقبالك 👨‍⚕️',
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              "الدور متوقف الآن عند الرقم: $currentNumber",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
