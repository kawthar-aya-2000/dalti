import 'package:dalti/booking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; 


class ClinicDetailPage extends StatelessWidget {
  final String clinicId;

  const ClinicDetailPage({super.key, required this.clinicId});

  void _callPhone(String phone) async {
  // ✅ نصحح الرقم إذا ما فيهش +213
  if (!phone.startsWith('+213') && phone.startsWith('0')) {
    phone = '+213${phone.substring(1)}';
  }

  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phone,
  );

  if (await canLaunchUrl(launchUri)) {
    await launchUrl(
      launchUri,
      mode: LaunchMode.externalApplication, // ✅ يفتح تطبيق الهاتف
    );
  } else {
    debugPrint("لا يمكن الاتصال بالرقم $phone");
  }
}

/*void _copyPhone(String phone, BuildContext context) async {
  await Clipboard.setData(ClipboardData(text: phone));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("📋 تم نسخ الرقم: $phone")),
  );
}*/

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تفاصيل العيادة"),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('clinics')
              .doc(clinicId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final clinic = snapshot.data!;
            if (!clinic.exists) {
              return const Center(child: Text("العيادة غير موجودة"));
            }

            final data = clinic.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة العيادة
                  //if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                  //  ClipRRect(
                  //    borderRadius: BorderRadius.circular(12),
                  //    child: Image.network(
                  //      data['imageUrl'],
                  //      height: 200,
                  //      width: double.infinity,
                  //      fit: BoxFit.cover,
                  //    ),
                  //  ),
                  //const SizedBox(height: 16),

                  // اسم العيادة
                  Text(
                    data['name'] ?? 'اسم العيادة غير متوفر',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // اسم الطبيب
                  if (data['doctorName'] != null)
                    Text(
                      "الطبيب: ${data['doctorName']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 8),

                  // العنوان
                  if (data['address'] != null)
                    Text(
                      "العنوان: ${data['address']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 8),

                  // رقم الهاتف تفاعلي
/*if (data['phone'] != null)
  GestureDetector(
    onTap: () => _copyPhone(data['phone'], context), // 👈 نستعمل الفانكشن لي عندك
    child: Row(
      children: [
        const Icon(Icons.phone, color: Colors.teal),
        const SizedBox(width: 8),
        Text(
          data['phone'],
          style: const TextStyle(
            fontSize: 16,
            color: Colors.teal,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    ),
  ),*/
  if (data['phone'] != null)
  GestureDetector(
    onTap: () => _callPhone(data['phone']), // ✅ يستعمل الفانكشن لي عندك
    child: Row(
      children: [
        const Icon(Icons.phone, color: Colors.teal),
        const SizedBox(width: 8),
        Text(
          data['phone'],
          style: const TextStyle(
            fontSize: 16,
            color: Colors.teal,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    ),
  ),


                  const SizedBox(height: 16),

                  // التخصصات
                  if (data['specialities'] != null)
                    Text(
                      "التخصص: ${data['specialities']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 16),

                  // ساعات العمل
                  if (data['workHours'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ساعات العمل:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...List.generate(data['workHours'].keys.length, (
                          index,
                        ) {
                          final day = data['workHours'].keys.elementAt(index);
                          final hours = data['workHours'][day];
                          return Text("$day: $hours");
                        }),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // حالة الحجز اليوم
                  if (data['booking'] != null)
                    Row(
                      children: [
                        Icon(
                          data['booking']['availableToday'] == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: data['booking']['availableToday'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data['booking']['availableToday'] == true
                              ? "العيادة متاحة اليوم"
                              : "العيادة غير متاحة اليوم",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // الإعلانات
                  if (data['announcements'] != null &&
                      data['announcements'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "الإعلانات:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(data['announcements'].length, (index) {
                          final announcement = data['announcements'][index];
                          String dateStr = '';
                          if (announcement['date'] != null) {
                            final ts = announcement['date'];
                            if (ts is Timestamp) {
                              final dt = ts.toDate();
                              dateStr = "${dt.day}/${dt.month}/${dt.year}";
                            }
                          }
                          return Card(
                            color: Colors.teal.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(announcement['title'] ?? ''),
                              subtitle: Text(announcement['content'] ?? ''),
                              trailing: Text(
                                dateStr,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // زر حجز موعد
                  ElevatedButton.icon(
                    onPressed: () {
                      if (data['booking'] != null &&
                          data['booking']['availableToday'] == true) {
                        // التنقل إلى صفحة الحجز
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingPage(
                              clinicId: clinicId,
                              clinicName: data['name'],
                              doctorName: data['doctorName'],
                            ),
                          ),
                        );
                      } else {
                        // عرض رسالة أن الحجز غير متاح
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("الحجز غير متاح اليوم")),
                        );
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("حجز موعد"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size.fromHeight(50),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
