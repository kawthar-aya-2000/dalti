
// functions/index.js
const admin = require("firebase-admin");

function initFirebase() {
  // الأفضل: ألعبي secret اسمه FIREBASE_SERVICE_ACCOUNT ويحتوي JSON كامل
  const saEnv = process.env.FIREBASE_SERVICE_ACCOUNT; // <-- preferred (JSON)
  const gac = process.env.GOOGLE_APPLICATION_CREDENTIALS; // <-- possible path to file

  if (saEnv) {
    // لو عطينا JSON في secret: نحلّيه ونستعمله مباشرة
    try {
      const serviceAccount = JSON.parse(saEnv);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      console.log("✅ Firebase initialized from FIREBASE_SERVICE_ACCOUNT (JSON).");
    } catch (err) {
      console.error("❌ FIREBASE_SERVICE_ACCOUNT is not valid JSON:", err.message);
      process.exit(1);
    }
  } else if (gac) {
    // لو عطيتِ مسار ملف في GOOGLE_APPLICATION_CREDENTIALS استخدم applicationDefault
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
    console.log("✅ Firebase initialized using GOOGLE_APPLICATION_CREDENTIALS (file path).");
  } else {
    console.error("❌ No credentials found. Set FIREBASE_SERVICE_ACCOUNT (preferred) or GOOGLE_APPLICATION_CREDENTIALS.");
    process.exit(1);
  }
}

initFirebase();
const db = admin.firestore();

async function deleteOldAppointments() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const snapshot = await db.collection("appointments")
    .where("createdAt", "<", admin.firestore.Timestamp.fromDate(today))
    .get();

  if (snapshot.empty) {
    console.log("✅ لا يوجد appointments قديمة");
    return;
  }

  const batch = db.batch();
  snapshot.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();

  console.log(`🗑️ تم مسح ${snapshot.size} من appointments القديمة`);
}

async function resetClinicQueues() {
  const snapshot = await db.collection("clinics").get();

  if (snapshot.empty) {
    console.log("✅ لا يوجد عيادات");
    return;
  }

  const batch = db.batch();
  snapshot.forEach((doc) => {
    batch.update(doc.ref, {
      "booking.queue.currentNumber": 0,
    });
  });

  await batch.commit();
  console.log(`🔄 تم تصفير queue لكل ${snapshot.size} عيادة`);
}

(async () => {
  await deleteOldAppointments();
  await resetClinicQueues();
})();
