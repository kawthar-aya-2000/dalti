/*const admin = require("firebase-admin");
const serviceAccount = JSON.parse(process.env.GOOGLE_APPLICATION_CREDENTIALS);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

(async () => {
  const db = admin.firestore();

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const snapshot = await db.collection("appointments")
    .where("createdAt", "<", admin.firestore.Timestamp.fromDate(today))
    .get();

  const batch = db.batch();
  snapshot.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();

  console.log("✅ appointments القديمة تم مسحها بنجاح");
})();*/
const admin = require("firebase-admin");
const serviceAccount = JSON.parse(process.env.GOOGLE_APPLICATION_CREDENTIALS);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

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
