OfflineQueue - Flutter Offline-First Notes App

A Flutter application demonstrating offline-first architecture with local SQLite storage and cloud synchronization using Firebase Firestore. This app allows users to create notes offline and automatically syncs them when connectivity is restored.

1.Prompt


How to design an offline-first sync queue in Flutter using Hive? I need persistent queue storage, retry support, idempotency handling,and durability across app restarts. The queue should support add_note and update_note actions.


2.Prompt (Iteration)


How can I prevent duplicate writes when retrying offline sync operations in Firestore?I need idempotent behavior for add_note actions.


3.Prompt


What is a simple retry mechanism suitable for a mobile offline sync queue? I want to avoid battery drain and infinite retries.



📱 Features
Offline-First Architecture: Create and view notes without an internet connection

Local Storage: SQLite database for persistent local storage

Cloud Synchronization: Automatic sync with Firebase Firestore when online

Sync Queue Management: Reliable queue system for pending sync operations

Idempotent Operations: Prevents duplicate sync operations

Modern UI: Beautiful gradient designs with smooth animations

Search Functionality: Search through notes locally

Multiple Views: List and grid view options for notes

Sync Status Indicators: Visual indicators for synced/unsynced notes


🏗️ Architecture
The app follows a clean architecture pattern with offline-first principles:

lib/core/services/db_helper.dart and sync_manager.dart


features/data/models/note_model.dart   


features/data/repository/node_repository.dart


features/presentation/screens/ home_screen.dart and add_note_screen.dart


features/presentation/widgets/note_card.dart


main.dart                         # App entry point



🗃️ Database Schema
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  isSynced INTEGER NOT NULL DEFAULT 0
)



Sync Queue Table
CREATE TABLE sync_queue(
  id TEXT PRIMARY KEY,
  actionType TEXT,
  payload TEXT,
  idempotencyKey TEXT,
  retryCount INTEGER,
  status TEXT,
  createdAt INTEGER
)



🔄 Synchronization Flow
Offline Creation: Notes are saved locally with isSynced = 0
Queue Management: Sync operations are queued in sync_queue table
Connectivity Detection: App listens to connectivity changes
Background Sync: When online, processes pending queue items
Idempotency Check: Prevents duplicate syncs using idempotency keys
Status Update: Marks notes as synced (isSynced = 1) after successful sync



🛠️ Technologies Used
Flutter: UI framework
sqflite: Local SQLite database
Firebase Core: Firebase initialization
Cloud Firestore: Cloud database
connectivity_plus: Network connectivity detection
path: Database path management




