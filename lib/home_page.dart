/*

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'clinics_page.dart';
import 'booking_confirmation_page.dart'; // لازم باش نروح لصفحة الموعد
import 'package:shared_preferences/shared_preferences.dart'; // جديد

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  String? selectedWilaya;

  bool hasBooking = false;
  String? clinicName;
  String? doctorName;
  String? patientName;
  int? queueNumber;
  String? clinicId;

  // قائمة الولايات
  final List<Map<String, String>> wilayas = [
    {"num": "1", "name": "أدرار"},
    {"num": "2", "name": "الشلف"},
    {"num": "3", "name": "الأغواط"},
    {"num": "4", "name": "أم البواقي"},
    {"num": "5", "name": "باتنة"},
    {"num": "6", "name": "بجاية"},
    {"num": "7", "name": "بسكرة"},
    {"num": "8", "name": "بشار"},
    {"num": "9", "name": "البليدة"},
    {"num": "10", "name": "البويرة"},
    {"num": "11", "name": "تمنراست"},
    {"num": "12", "name": "تبسة"},
    {"num": "13", "name": "تلمسان"},
    {"num": "14", "name": "تيارت"},
    {"num": "15", "name": "تيزي وزو"},
    {"num": "16", "name": "الجزائر"},
    {"num": "17", "name": "الجلفة"},
    {"num": "18", "name": "جيجل"},
    {"num": "19", "name": "سطيف"},
    {"num": "20", "name": "سعيدة"},
    {"num": "21", "name": "سكيكدة"},
    {"num": "22", "name": "سيدي بلعباس"},
    {"num": "23", "name": "عنابة"},
    {"num": "24", "name": "قالمة"},
    {"num": "25", "name": "قسنطينة"},
    {"num": "26", "name": "المدية"},
    {"num": "27", "name": "مستغانم"},
    {"num": "28", "name": "المسيلة"},
    {"num": "29", "name": "معسكر"},
    {"num": "30", "name": "ورقلة"},
    {"num": "31", "name": "وهران"},
    {"num": "32", "name": "البيض"},
    {"num": "33", "name": "إليزي"},
    {"num": "34", "name": "برج بوعريريج"},
    {"num": "35", "name": "بومرداس"},
    {"num": "36", "name": "الطارف"},
    {"num": "37", "name": "تندوف"},
    {"num": "38", "name": "تيسمسيلت"},
    {"num": "39", "name": "الوادي"},
    {"num": "40", "name": "خنشلة"},
    {"num": "41", "name": "سوق أهراس"},
    {"num": "42", "name": "تيبازة"},
    {"num": "43", "name": "ميلة"},
    {"num": "44", "name": "عين الدفلى"},
    {"num": "45", "name": "النعامة"},
    {"num": "46", "name": "عين تموشنت"},
    {"num": "47", "name": "غرداية"},
    {"num": "48", "name": "غليزان"},
    {"num": "49", "name": "تيميمون"},
    {"num": "50", "name": "برج باجي مختار"},
    {"num": "51", "name": "أولاد جلال"},
    {"num": "52", "name": "بني عباس"},
    {"num": "53", "name": "عين صالح"},
    {"num": "54", "name": "عين قزام"},
    {"num": "55", "name": "تقرت"},
    {"num": "56", "name": "جانت"},
    {"num": "57", "name": "المغير"},
    {"num": "58", "name": "المنيعة"},
  ];

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  Future<void> _loadBookingData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasBooking = prefs.getBool('hasBooking') ?? false;
      clinicName = prefs.getString('clinicName');
      doctorName = prefs.getString('doctorName');
      patientName = prefs.getString('patientName');
      queueNumber = prefs.getInt('queueNumber');
      clinicId = prefs.getString('clinicId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الصفحة الرئيسية"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil("/login", (route) => false);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "📅 مرحباً بك في تطبيق دالتي",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // إذا ما عندوش حجز → نظهر اختيار الولاية
              if (!hasBooking) ...[
                const Text(
                  "لحجز موعد اختر ولايتك:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "اختر الولاية",
                  ),
                  value: selectedWilaya,
                  items: wilayas.map((w) {
                    return DropdownMenuItem(
                      value: w["num"], // القيمة المخزنة = الرقم
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            w["num"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(w["name"]!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedWilaya = value;
                    });

                    if (value != null) {
                      final name = wilayas.firstWhere(
                        (w) => w["num"] == value,
                      )["name"]!;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClinicsPage(
                            wilayaName: name, // للعرض
                            wilayaNum: value, // للبحث في Firestore
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],

              const SizedBox(height: 30),

              // زر موعدي يظهر فقط إذا عندو حجز
              if (hasBooking)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmationPage(
                          clinicName: clinicName ?? "",
                          doctorName: doctorName ?? "",
                          patientName: patientName ?? "",
                          queueNumber: queueNumber ?? 0,
                          clinicId: clinicId ?? "",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.event_available),
                  label: const Text("موعدي"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'clinics_page.dart';
import 'booking_confirmation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedWilaya;

  // قائمة الولايات (كما عندك)
  final List<Map<String, String>> wilayas = [
    {"num": "1", "name": "أدرار"},
    {"num": "2", "name": "الشلف"},
    {"num": "3", "name": "الأغواط"},
    {"num": "4", "name": "أم البواقي"},
    {"num": "5", "name": "باتنة"},
    {"num": "6", "name": "بجاية"},
    {"num": "7", "name": "بسكرة"},
    {"num": "8", "name": "بشار"},
    {"num": "9", "name": "البليدة"},
    {"num": "10", "name": "البويرة"},
    {"num": "11", "name": "تمنراست"},
    {"num": "12", "name": "تبسة"},
    {"num": "13", "name": "تلمسان"},
    {"num": "14", "name": "تيارت"},
    {"num": "15", "name": "تيزي وزو"},
    {"num": "16", "name": "الجزائر"},
    {"num": "17", "name": "الجلفة"},
    {"num": "18", "name": "جيجل"},
    {"num": "19", "name": "سطيف"},
    {"num": "20", "name": "سعيدة"},
    {"num": "21", "name": "سكيكدة"},
    {"num": "22", "name": "سيدي بلعباس"},
    {"num": "23", "name": "عنابة"},
    {"num": "24", "name": "قالمة"},
    {"num": "25", "name": "قسنطينة"},
    {"num": "26", "name": "المدية"},
    {"num": "27", "name": "مستغانم"},
    {"num": "28", "name": "المسيلة"},
    {"num": "29", "name": "معسكر"},
    {"num": "30", "name": "ورقلة"},
    {"num": "31", "name": "وهران"},
    {"num": "32", "name": "البيض"},
    {"num": "33", "name": "إليزي"},
    {"num": "34", "name": "برج بوعريريج"},
    {"num": "35", "name": "بومرداس"},
    {"num": "36", "name": "الطارف"},
    {"num": "37", "name": "تندوف"},
    {"num": "38", "name": "تيسمسيلت"},
    {"num": "39", "name": "الوادي"},
    {"num": "40", "name": "خنشلة"},
    {"num": "41", "name": "سوق أهراس"},
    {"num": "42", "name": "تيبازة"},
    {"num": "43", "name": "ميلة"},
    {"num": "44", "name": "عين الدفلى"},
    {"num": "45", "name": "النعامة"},
    {"num": "46", "name": "عين تموشنت"},
    {"num": "47", "name": "غرداية"},
    {"num": "48", "name": "غليزان"},
    {"num": "49", "name": "تيميمون"},
    {"num": "50", "name": "برج باجي مختار"},
    {"num": "51", "name": "أولاد جلال"},
    {"num": "52", "name": "بني عباس"},
    {"num": "53", "name": "عين صالح"},
    {"num": "54", "name": "عين قزام"},
    {"num": "55", "name": "تقرت"},
    {"num": "56", "name": "جانت"},
    {"num": "57", "name": "المغير"},
    {"num": "58", "name": "المنيعة"},
  ];

  /// يبحث في Firestore إذا المريض عنده موعد اليوم ويرجع بياناته (أو null)
  Future<Map<String, dynamic>?> _fetchTodayAppointment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: user.uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // نرجع data كـ Map<String, dynamic>
        final data = snapshot.docs.first.data();
        // أضفنا معاها الـ doc id لو تحتاجيه لاحقاً
        data['__docId'] = snapshot.docs.first.id;
        return data;
      } else {
        return null;
      }
    } catch (e) {
      // لو صار خطأ نطبع في الـ console ونعطي null حتى لا يكسر الـ UI
      // (بإمكانك استبدال print بـ logger متطور)
      print('Error fetching today appointment: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الصفحة الرئيسية"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/login", (route) => false);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _fetchTodayAppointment(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                // خطأ في القراءة من Firebase
                return Center(
                  child: Text(
                    "حصل خطأ أثناء جلب بيانات الحجز. جرّب إعادة التشغيل.",
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final appointment = snapshot.data;

              // إذا عنده موعد اليوم → نعرض زر "موعدي"
              if (appointment != null) {
                // نحضّر القيم مع التأكد من أنواعها
                final clinicName = appointment['clinicName'] as String? ?? '';
                final doctorName = appointment['doctorName'] as String? ?? '';

                final String patientFirst =
                    appointment['patientName'] as String? ?? '';
                final String patientLast =
                    appointment['patientLastName'] as String? ?? '';
                final String patientFull =
                    (patientFirst + (patientLast.isNotEmpty ? ' $patientLast' : '')).trim();

                final queueRaw = appointment['queueNumber'];
                final int queueNumber = queueRaw is int
                    ? queueRaw
                    : (queueRaw is num ? queueRaw.toInt() : 0);

                final clinicId = appointment['clinicId'] as String? ?? '';

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "لديك موعد اليوم",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingConfirmationPage(
                              clinicName: clinicName,
                              doctorName: doctorName,
                              patientName: patientFull,
                              queueNumber: queueNumber,
                              clinicId: clinicId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.event_available),
                      label: const Text("موعدي"),
                    ),
                    const SizedBox(height: 24),
                    // رابط للذهاب لاختيار ولاية جديدة (اختياري)
                    /*TextButton(
                      onPressed: () {
                        setState(() {
                          selectedWilaya = null;
                        });
                      },
                      child: const Text("إظهار خيارات الحجز"),
                    ),*/
                  ],
                );
              }

              // إذا ما عندوش موعد → نعرض اختيار الولاية
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "📅 مرحباً بك في تطبيق دالتي",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "لحجز موعد اختر ولايتك:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "اختر الولاية",
                      ),
                      value: selectedWilaya,
                      items: wilayas.map((w) {
                        return DropdownMenuItem(
                          value: w["num"],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(w["num"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text(w["name"]!),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedWilaya = value;
                        });

                        if (value != null) {
                          final name = wilayas.firstWhere((w) => w["num"] == value)["name"]!;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClinicsPage(
                                wilayaName: name,
                                wilayaNum: value,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

