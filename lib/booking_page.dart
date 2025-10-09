/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_confirmation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingPage extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final String doctorName;

  const BookingPage({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.doctorName,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final appointmentsRef = FirebaseFirestore.instance.collection('appointments');
  final clinicsRef = FirebaseFirestore.instance.collection('clinics');

    /// نتأكد أن حقل queue موجود
  Future<void> ensureQueueField() async {
    final clinicRef = clinicsRef.doc(widget.clinicId);
    final snapshot = await clinicRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data != null &&
        (data['booking'] == null ||
            !(data['booking'] as Map).containsKey('queue'))) {
      await clinicRef.update({
        'booking.queue': {
          'currentNumber': 0,
          'totalNumber': 0, // زدنا الحقل الجديد
        },
      });
    }
  }

  /// نجيب رقم الدور الجديد (totalNumber) باستخدام Transaction
  Future<int> getNextQueueNumber() async {
    final clinicRef = clinicsRef.doc(widget.clinicId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(clinicRef);

      // totalNumber يزيد كل مرة واحد
      final totalNumber =
          (snapshot.data()?['booking']?['queue']?['totalNumber'] as int?) ?? 0;
      final nextTotalNumber = totalNumber + 1;

      // نكتب التحديث
      transaction.update(clinicRef, {
        'booking.queue.totalNumber': nextTotalNumber,
      });

      return nextTotalNumber; // هذا يرجع رقم الدور للمريض
    });
  }


  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      final patientName = _nameController.text.trim();
      final patientLastName = _lastNameController.text.trim();
      final patientPhone = _phoneController.text.trim();
      final patientId = FirebaseAuth.instance.currentUser!.uid;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // هل عندو حجز اليوم؟
      final existingAppointments = await appointmentsRef
          .where('patientId', isEqualTo: patientId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (existingAppointments.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("تنبيه"),
            content: const Text("لا يمكنك حجز أكثر من موعد واحد في نفس اليوم."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("موافق"),
              ),
            ],
          ),
        );
        return;
      }

      // تأكد حقل queue
      await ensureQueueField();
      final queueNumber = await getNextQueueNumber();

      // إضافة الحجز
      await appointmentsRef.add({
        'clinicId': widget.clinicId,
        'clinicName': widget.clinicName,
        'doctorName': widget.doctorName,
        'patientId': patientId,
        'patientName': patientName,
        'patientLastName': patientLastName,
        'patientPhone': patientPhone,
        'createdAt': Timestamp.fromDate(now),
        'status': 'pending',
        'queueNumber': queueNumber,
      });

      // تخزين بيانات الحجز محليا
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasBooking', true);
      await prefs.setString('clinicName', widget.clinicName);
      await prefs.setString('doctorName', widget.doctorName);
      await prefs.setString('patientName', "$patientName $patientLastName");
      await prefs.setInt('queueNumber', queueNumber);
      await prefs.setString('clinicId', widget.clinicId);

      // الانتقال لصفحة تأكيد الحجز
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(
            clinicName: widget.clinicName,
            doctorName: widget.doctorName,
            patientName: "$patientName $patientLastName",
            queueNumber: queueNumber,
            clinicId: widget.clinicId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("حجز موعد"),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  widget.clinicName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "الطبيب: ${widget.doctorName}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "الاسم",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "أدخل اسمك" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: "اللقب",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "أدخل لقبك" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "رقم الهاتف",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value == null || value.isEmpty ? "أدخل رقم هاتفك" : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _bookAppointment,
                  icon: const Icon(Icons.check),
                  label: const Text("تأكيد الحجز"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size.fromHeight(50),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_confirmation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class BookingPage extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final String doctorName;

  const BookingPage({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.doctorName,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final appointmentsRef = FirebaseFirestore.instance.collection('appointments');
  final clinicsRef = FirebaseFirestore.instance.collection('clinics');

  Future<void> ensureQueueField() async {
    final clinicRef = clinicsRef.doc(widget.clinicId);
    final snapshot = await clinicRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data != null &&
        (data['booking'] == null ||
            !(data['booking'] as Map).containsKey('queue'))) {
      await clinicRef.update({
        'booking.queue': {
          'currentNumber': 0,
          'totalNumber': 0,
        },
      });
    }
  }

  Future<int> getNextQueueNumber() async {
    final clinicRef = clinicsRef.doc(widget.clinicId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(clinicRef);
      final totalNumber =
          (snapshot.data()?['booking']?['queue']?['totalNumber'] as int?) ?? 0;
      final nextTotalNumber = totalNumber + 1;

      transaction.update(clinicRef, {
        'booking.queue.totalNumber': nextTotalNumber,
      });

      return nextTotalNumber;
    });
  }

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      final patientName = _nameController.text.trim();
      final patientLastName = _lastNameController.text.trim();
      final patientPhone = _phoneController.text.trim();
      final patientId = FirebaseAuth.instance.currentUser!.uid;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingAppointments = await appointmentsRef
          .where('patientId', isEqualTo: patientId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (existingAppointments.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("تنبيه"),
            content: const Text("لا يمكنك حجز أكثر من موعد واحد في نفس اليوم."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("موافق"),
              ),
            ],
          ),
        );
        return;
      }

      await ensureQueueField();
      final queueNumber = await getNextQueueNumber();

      await appointmentsRef.add({
        'clinicId': widget.clinicId,
        'clinicName': widget.clinicName,
        'doctorName': widget.doctorName,
        'patientId': patientId,
        'patientName': patientName,
        'patientLastName': patientLastName,
        'patientPhone': patientPhone,
        'createdAt': Timestamp.fromDate(now),
        'status': 'pending',
        'queueNumber': queueNumber,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasBooking', true);
      await prefs.setString('clinicName', widget.clinicName);
      await prefs.setString('doctorName', widget.doctorName);
      await prefs.setString('patientName', "$patientName $patientLastName");
      await prefs.setInt('queueNumber', queueNumber);
      await prefs.setString('clinicId', widget.clinicId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(
            clinicName: widget.clinicName,
            doctorName: widget.doctorName,
            patientName: "$patientName $patientLastName",
            queueNumber: queueNumber,
            clinicId: widget.clinicId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.teal;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF8F7),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ رأس الصفحة المتموج
              Stack(
                children: [
                  ClipPath(
                    clipper: WaveClipperTwo(reverse: false),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          child: Column(
                            children: [
                              Text(
                                widget.clinicName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "الطبيب: ${widget.doctorName}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ✅ باقي الصفحة (الفورم)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "الاسم",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "أدخل اسمك" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: "اللقب",
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "أدخل لقبك" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: "رقم الهاتف",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? "أدخل رقم هاتفك"
                            : null,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: _bookAppointment,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("تأكيد الحجز"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
