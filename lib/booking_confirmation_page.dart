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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تأكيد الحجز"),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                clinicName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text("الطبيب: $doctorName", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 6),
              Text("المريض: $patientName", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),

              // رقم الدور
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
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 40),

              // الدور الحالي (live من العيادة)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("clinics")
                    .doc(clinicId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final clinicData = snapshot.data!;
                  final currentNumber = clinicData['currentNumber'] ?? 0;

                  return Text(
                    "الدور متوقف الآن عند الرقم: $currentNumber",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تأكيد الحجز"),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(clinicName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("الطبيب: $doctorName", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 6),
              Text("المريض: $patientName", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),

              const Text("رقم دورك هو:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.teal.shade100,
                ),
                child: Text(
                  "$queueNumber",
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),

              // الدور الحالي (من Firestore)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("clinics")
                    .doc(clinicId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final clinicData = snapshot.data!;
                  final currentNumber = clinicData['currentNumber'] ?? 0;

                  return Text(
                    "الدور متوقف الآن عند الرقم: $currentNumber",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/ 