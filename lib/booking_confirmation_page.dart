
/*
import 'package:dalti/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingConfirmationPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 🔒 ما يخليش المستخدم يرجع
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          /*appBar: AppBar(
            title: const Text("تأكيد الحجز"),
            backgroundColor: Colors.teal,
            centerTitle: true,
            automaticallyImplyLeading: false, // 🔒 يخفي زر الرجوع
          ),*/
          appBar: AppBar(
            title: const Text("تأكيد الحجز"),
            backgroundColor: Colors.teal,
            centerTitle: true,
            automaticallyImplyLeading:
                false, // نخليها false باش ما يظهرش زر الرجوع الافتراضي
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false, // نحذف كل الصفحات السابقة من الستاك
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
                  clinicName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "الطبيب: $doctorName",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  "المريض: $patientName",
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
                    "$queueNumber",
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
                      .doc(clinicId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final clinicData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    final currentNumber =
                        clinicData?['booking']?['queue']?['currentNumber'] ?? 0;

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
}*/
 // الاشعاارت
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

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'queue_channel',
      'إشعارات الدور',
      channelDescription: 'إشعار عندما يحين دورك في العيادة',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'دورك الآن!',
      'الطبيب ${widget.doctorName} جاهز لاستقبالك.',
      details,
    );
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
                Text("الطبيب: ${widget.doctorName}",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 6),
                Text("المريض: ${widget.patientName}",
                    style: const TextStyle(fontSize: 18)),
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
                    if (!notified) {
  final int current = (currentNumber is int)
      ? currentNumber
      : (currentNumber is double)
          ? currentNumber.toInt()
          : int.tryParse(currentNumber.toString()) ?? 0;

  if (current == widget.queueNumber) {
    notified = true;
    Future.delayed(const Duration(milliseconds: 500), _showNotification);
  }
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
                ElevatedButton(
  onPressed: () async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'اختبار الإشعارات 🎉',
      'إذا شفت هذا التنبيه، فالإعدادات كلها تمام ✅',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  },
  child: const Text('تجربة إشعار'),
),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

