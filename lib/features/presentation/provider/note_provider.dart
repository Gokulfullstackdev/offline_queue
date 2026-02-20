import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:offline_queue/core/services/db_helper.dart';

class SyncManager {
  final dbHelper = DatabaseHelper.instance;
  final firestore = FirebaseFirestore.instance;

  Future<void> processQueue() async {
    final db = await dbHelper.database;

    final items = await db.query(
      "sync_queue",
      where: "status = ?",
      whereArgs: ["pending"],
    );

    print("Queue size: ${items.length}");

    for (var item in items) {
      try {
        final actionType = item["actionType"];
        final payload = jsonDecode(item["payload"].toString());
        final idempotencyKey = item["idempotencyKey"].toString();

        final idempotentCheck = await firestore
            .collection("idempotency")
            .doc(idempotencyKey)
            .get();

        if (!idempotentCheck.exists) {
          if (actionType == "add_note") {
            await firestore.collection("notes").doc(payload["id"]).set(payload);
          }

          await firestore.collection("idempotency").doc(idempotencyKey).set({
            "done": true,
          });
        }

        await db.delete("sync_queue", where: "id = ?", whereArgs: [item["id"]]);

        await db.update(
          "notes",
          {"isSynced": 1},
          where: "id = ?",
          whereArgs: [payload["id"]],
        );

        print("Sync success");
      } catch (e) {
        print("Sync failed: $e");
      }
    }
  }
}
