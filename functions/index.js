const admin = require("firebase-admin");
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
})();
