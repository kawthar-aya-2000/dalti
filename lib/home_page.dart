/*import 'package:flutter/material.dart';
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
              Text(
                "📅 مرحباً بك في تطبيق دالتي",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

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
}
