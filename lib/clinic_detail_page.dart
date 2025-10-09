/*import 'package:dalti/booking_page.dart';
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
}*/
import 'package:dalti/booking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ClinicDetailPage extends StatelessWidget {
  final String clinicId;

  const ClinicDetailPage({super.key, required this.clinicId});

  void _callPhone(String phone) async {
    if (!phone.startsWith('+213') && phone.startsWith('0')) {
      phone = '+213${phone.substring(1)}';
    }

    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("لا يمكن الاتصال بالرقم $phone");
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006D77);
    const secondaryColor = Color(0xFF83C5BE);
    const backgroundColor = Color(0xFFEDF6F9);
    const textColor = Color(0xFF1B262C);
    const accentColor = Color(0xFFFFDDD2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text("تفاصيل العيادة", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
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
              child: Column(
                children: [
                  // 🩺 رأس الصفحة بتصميم متموج جميل
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 40, bottom: 40),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*const Icon(Icons.local_hospital,
                              color: Colors.white, size: 60),
                          const SizedBox(height: 12),*/
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  data['name'] ?? 'اسم العيادة غير متوفر',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (data['doctorName'] != null)
                                  Text(
                                    "د. ${data['doctorName']}",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white70),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🩹 باقي التفاصيل
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _infoCard(Icons.location_on, "العنوان",
                            data['address'] ?? 'غير متوفر', primaryColor),
                        if (data['phone'] != null)
                          _infoCard(Icons.phone, "رقم الهاتف", data['phone'],
                              primaryColor,
                              onTap: () => _callPhone(data['phone']),
                              isLink: true),
                        if (data['specialities'] != null)
                          _infoCard(Icons.medical_information, "التخصص",
                              data['specialities'], primaryColor),

                        const SizedBox(height: 12),

                        // ساعات العمل
                        if (data['workHours'] != null)
                          _sectionCard(
                            title: "ساعات العمل",
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: data['workHours'].keys.map<Widget>((day) {
                                final hours = data['workHours'][day];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(day,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(hours),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            color: accentColor,
                          ),

                        // حالة التوفر
                        if (data['booking'] != null)
                          _sectionCard(
                            title: "التوفر اليوم",
                            child: Row(
                              children: [
                                Icon(
                                  data['booking']['availableToday'] == true
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color:
                                      data['booking']['availableToday'] == true
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
                            color: Colors.white,
                          ),

                        // الإعلانات
                        if (data['announcements'] != null &&
                            data['announcements'].isNotEmpty)
                          _sectionCard(
                            title: "الإعلانات",
                            child: Column(
                              children: List.generate(
                                  data['announcements'].length, (index) {
                                final announcement =
                                    data['announcements'][index];
                                String dateStr = '';
                                if (announcement['date'] != null) {
                                  final ts = announcement['date'];
                                  if (ts is Timestamp) {
                                    final dt = ts.toDate();
                                    dateStr =
                                        "${dt.day}/${dt.month}/${dt.year}";
                                  }
                                }
                                return Card(
                                  color: secondaryColor.withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: const Icon(Icons.campaign,
                                        color: primaryColor),
                                    title:
                                        Text(announcement['title'] ?? 'إعلان'),
                                    subtitle:
                                        Text(announcement['content'] ?? ''),
                                    trailing: Text(
                                      dateStr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            color: Colors.white,
                          ),

                        const SizedBox(height: 20),

                        // زر الحجز العصري
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (data['booking'] != null &&
                                  data['booking']['availableToday'] == true) {
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("الحجز غير متاح اليوم")),
                                );
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text("احجز موعدك الآن"),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

  Widget _infoCard(IconData icon, String title, String value, Color color,
      {VoidCallback? onTap, bool isLink = false}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(
          value,
          style: TextStyle(
            color: isLink ? color : Colors.black87,
            decoration:
                isLink ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
        trailing: isLink ? Icon(Icons.call, color: color) : null,
      ),
    );
  }

  Widget _sectionCard(
      {required String title,
      required Widget child,
      required Color color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// 🎨 ويف متموج للرأس
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
