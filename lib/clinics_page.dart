/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinic_detail_page.dart';

class ClinicsPage extends StatefulWidget {
  final String wilayaName; // اسم الولاية للعرض فقط
  final String wilayaNum;  // رقم الولاية للبحث في Firestore

  const ClinicsPage({
    super.key,
    required this.wilayaName,
    required this.wilayaNum,
  });

  @override
  State<ClinicsPage> createState() => _ClinicsPageState();
}

class _ClinicsPageState extends State<ClinicsPage> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("عيادات ${widget.wilayaName}"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          // خانة البحث
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن عيادة أو طبيب...",
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          // القائمة
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("clinics")
                  .where("wilaya", isEqualTo: widget.wilayaNum) // 🔹 البحث بالرقم
                  .where("isActive", isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // فلترة حسب البحث
                final filtered = docs.where((doc) {
                  final name = doc["name"].toString();
                  final doctor = doc["doctorName"].toString();
                  final query = searchText.toLowerCase();
                  return name.toLowerCase().contains(query) ||
                      doctor.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد عيادات مطابقة",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final clinic = filtered[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal[100],
                          child: const Icon(Icons.local_hospital, color: Colors.teal),
                        ),
                        title: Text(
                          clinic["name"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text("الطبيب: ${clinic["doctorName"]}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClinicDetailPage(
                                clinicId: clinic.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/
//ديزاين
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinic_detail_page.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class ClinicsPage extends StatefulWidget {
  final String wilayaName; // اسم الولاية للعرض فقط
  final String wilayaNum; // رقم الولاية للبحث في Firestore

  const ClinicsPage({
    super.key,
    required this.wilayaName,
    required this.wilayaNum,
  });

  @override
  State<ClinicsPage> createState() => _ClinicsPageState();
}

class _ClinicsPageState extends State<ClinicsPage> {
  String searchText = "";
  String? _selectedSpeciality; // ✅ تخصص محدد من الفلترة

  final Color primaryColor = const Color(0xFF006D77);
  final Color secondaryColor = const Color(0xFF83C5BE);
  final Color backgroundColor = const Color(0xFFEDF6F9);
  final Color accentColor = const Color(0xFFFFDDD2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // 🌊 AppBar متموجة
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipperTwo(),
                child: Container(height: 190, color: secondaryColor),
              ),
              ClipPath(
                clipper: WaveClipperOne(),
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "عيادات ${widget.wilayaName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 🔍 خانة البحث
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن عيادة أو طبيب...",
                prefixIcon: Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: secondaryColor, width: 1.2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          // 🩺 زر فلترة حسب التخصص
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
              icon: const Icon(Icons.filter_list),
              label: Text(
                _selectedSpeciality == null
                    ? "فلترة حسب التخصص"
                    : "التخصص: $_selectedSpeciality",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final selected = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    final specialities = [
                      'طب عام',
                      'أمراض القلب',
                      'الأنف والأذن والحنجرة',
                      'طب العيون',
                      'طب الأطفال',
                      'جراحة الاطفال',
                      'الأمراض الجلدية',
                      'جراحة عامة',
                      'أمراض النساء والتوليد',
                      'العظام والمفاصل',
                      'طب الأسنان',
                      'اخصائي علم النفس',
                      'الامراض العقلية والنفسية',
                      'المسالك البولية',
                      'أمراض الكلى',
                      'أمراض الجهاز الهضمي',
                      'الأشعة',
                      'التخدير والإنعاش',
                      'الطب الباطني (الداخلي)',
                      'طب وجراحة المخ والأعصاب',
                      'مرض السكري والغدد الصماء',
                      'طب الأمراض الصدرية والتنفسية',
                      'طب أمراض الدم',
                      'طب الأورام',
                      'عيادة أرطفونية',
                      'أمراض الحساسية',
                      'طب التغذية والحمية',
                      'الطب الفيزيائي وإعادة التأهيل الحركي',
                      'القابلة',
                      'الأمراض المعدية',
                      'الطب النووي',
                      'مركز علاج الإدمان',
                      'طب وجراحة تجميلية',
                      'أخرى',
                    ];

                    return SimpleDialog(
                      title: const Text("اختر التخصص"),
                      children: [
                        ...specialities.map((s) => SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, s),
                              child: Text(s),
                            )),
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, "الكل"),
                          child: const Text(
                            "عرض الكل",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (selected != null && mounted) {
                  setState(() {
                    _selectedSpeciality =
                        (selected == "الكل") ? null : selected;
                  });
                }
              },
            ),
          ),

          // 📋 قائمة العيادات
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (_selectedSpeciality != null)
                  ? FirebaseFirestore.instance
                      .collection("clinics")
                      .where("wilaya", isEqualTo: widget.wilayaNum)
                      .where("isActive", isEqualTo: true)
                      .where("specialities", isEqualTo: _selectedSpeciality)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("clinics")
                      .where("wilaya", isEqualTo: widget.wilayaNum)
                      .where("isActive", isEqualTo: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // فلترة حسب البحث
                final filtered = docs.where((doc) {
                  final name = doc["name"].toString().toLowerCase();
                  final doctor = doc["doctorName"].toString().toLowerCase();
                  final query = searchText.toLowerCase();
                  return name.contains(query) || doctor.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد عيادات مطابقة 🔍",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final clinic = filtered[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: accentColor,
                          child: Icon(
                            Icons.medical_information,
                            color: primaryColor,
                            size: 26,
                          ),
                        ),
                        title: Text(
                          clinic["name"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          "الطبيب: ${clinic["doctorName"]}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 18, color: secondaryColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClinicDetailPage(clinicId: clinic.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
