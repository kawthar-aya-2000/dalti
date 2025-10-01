const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.deleteOldAppointments = functions.pubsub
  .schedule("0 0 * * *") // كل يوم على الساعة 00:00
  .timeZone("Africa/Algiers") // المنطقة الزمنية الجزائر
  .onRun(async (context) => {
    const db = admin.firestore();

    const today = new Date();
    today.setHours(0, 0, 0, 0); // بداية اليوم

    const snapshot = await db.collection("appointments")
      .where("createdAt", "<", admin.firestore.Timestamp.fromDate(today))
      .get();

    const batch = db.batch();
    snapshot.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    console.log("✅ appointments القديمة تم مسحها بنجاح");
    return null;
  });

