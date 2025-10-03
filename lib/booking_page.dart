/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^(05|06|07)\d{8}$');
    return regex.hasMatch(phone);
  }

  Future<void> _bookAppointment() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ الرجاء ملء جميع الخانات")),
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ الرجاء إدخال رقم هاتف جزائري صحيح (10 أرقام يبدأ بـ 05/06/07)"),
        ),
      );
      return;
    }

    try {
      final docRef = await _firestore.collection("appointments").add({
        "clinicId": widget.clinicId,
        "clinicName": widget.clinicName,
        "doctorName": widget.doctorName,
        "patientFirstName": firstName,
        "patientLastName": lastName,
        "phoneNumber": phone,
        "status": "في الانتظار",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await docRef.update({"appointmentId": docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✅ تم حجز الدور بانتظار التأكيد من طرف الممرض.\nقد تتلقى مكالمة هاتفية.",
          ),
        ),
      );

      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( // ✅ RTL
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("حجز موعد"),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🏥 العيادة: ${widget.clinicName}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("👨‍⚕️ الطبيب: ${widget.doctorName}",
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),

              // 🔹 حقول الإدخال في Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: "الاسم",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: "اللقب",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "رقم الهاتف",
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 زر الحجز
              ElevatedButton.icon(
                onPressed: _bookAppointment,
                icon: const Icon(Icons.check_circle),
                label: const Text("تأكيد الحجز"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(55),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
// 2

/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // المتحكمين في الحقول
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      final patientName = _nameController.text.trim();
      final patientLastName = _lastNameController.text.trim();
      final patientPhone = _phoneController.text.trim();
      final patientId = FirebaseAuth.instance.currentUser!.uid;

      // حساب بداية ونهاية اليوم
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final appointmentsRef =
          FirebaseFirestore.instance.collection('appointments');

      // التحقق إذا عندو حجز اليوم
      final existingAppointments = await appointmentsRef
          .where('patientId', isEqualTo: patientId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (existingAppointments.docs.isNotEmpty) {
        // عندو حجز
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

      // إضافة الحجز
      await appointmentsRef.add({
        'clinicId': widget.clinicId,
        'clinicName': widget.clinicName,
        'doctorName': widget.doctorName,
        'patientId': patientId,
        'patientName': patientName,
        'patientLastName': patientLastName,
        'patientPhone': patientPhone,
        'createdAt': Timestamp.fromDate(now), // ⚡ نفس الاسم لي درتيه في index
        'status': 'pending',
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("تم الحجز"),
          content: const Text(
              "تم حجز الدور بنجاح بانتظار التأكيد من طرف الممرض. قد تتلقى مكالمة هاتفية."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("موافق"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // الصفحة بالعربية
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
                // اسم العيادة
                Text(
                  widget.clinicName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // اسم الطبيب
                Text(
                  "الطبيب: ${widget.doctorName}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // خانة الاسم
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

                // خانة اللقب
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

                // خانة رقم الهاتف
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

                // زر الحجز
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
//3
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_confirmation_page.dart';

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

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      final patientName = _nameController.text.trim();
      final patientLastName = _lastNameController.text.trim();
      final patientPhone = _phoneController.text.trim();
      final patientId = FirebaseAuth.instance.currentUser!.uid;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final appointmentsRef =
          FirebaseFirestore.instance.collection('appointments');

      // هل عندو حجز اليوم؟
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

      // حساب رقم الدور (عدد المواعيد اليوم + 1)
      final todayAppointments = await appointmentsRef
          .where('clinicId', isEqualTo: widget.clinicId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final queueNumber = todayAppointments.docs.length + 1;

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
                Text(widget.clinicName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("الطبيب: ${widget.doctorName}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),

                // الاسم
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "الاسم",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "أدخل اسمك" : null,
                ),
                const SizedBox(height: 16),

                // اللقب
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: "اللقب",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "أدخل لقبك" : null,
                ),
                const SizedBox(height: 16),

                // الهاتف
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "رقم الهاتف",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value == null || value.isEmpty ? "أدخل رقم هاتفك" : null,
                ),
                const SizedBox(height: 24),

                // زر الحجز
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
        'booking.queue': {'currentNumber': 0},
      });
    }
  }

  /// نجيب رقم الدور الجديد باستخدام Transaction
  Future<int> getNextQueueNumber() async {
    final clinicRef = clinicsRef.doc(widget.clinicId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(clinicRef);
      final currentNumber =
          snapshot.get('booking.queue.currentNumber') as int? ?? 0;
      final nextNumber = currentNumber + 1;

      transaction.update(clinicRef, {
        'booking.queue.currentNumber': nextNumber,
      });

      return nextNumber;
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
}
