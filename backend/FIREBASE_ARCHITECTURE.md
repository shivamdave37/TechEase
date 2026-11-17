# Backend & Firebase Architecture Specification

## 1. Architecture Overview
The Elderly Smartphone Learning App is engineered using a **Local-First, Cloud-Synced** pattern. 
- The client application operates completely offline without network latency, persisting lessons, progress, and bookmarks locally.
- When internet connectivity and Firebase configuration credentials (`google-services.json` for Android, `GoogleService-Info.plist` for iOS, and `firebase_options.dart` for Web) are supplied, the application synchronizes with Google Cloud / Firebase services.

## 2. Firebase Services Mapping
| Service | Purpose in App | Security & Access |
|---|---|---|
| **Firebase Authentication** | Simple SMS Phone Authentication (with optional Google Sign-in / Guest Mode) | Secure JWT tokens; phone numbers masked in Firestore |
| **Cloud Firestore** | Structured storage for user profiles, progress, categories, community video metadata, voice group threads, and moderation queues | Governed by `backend/firestore.rules` |
| **Cloud Storage** | Secure hosting of community learning videos (`/community_videos/`) and encrypted voice recordings (`/voice_recordings/`) | Governed by `backend/storage.rules` |
| **Firebase Cloud Functions (Optional)** | Automated video transcode/thumbnail generation, profanity filters, and push notifications for new group voice messages | Server-side secure triggers |

## 3. Database Schema (Firestore Collections)
```
/users/{userId}
  - displayName: string
  - maskedPhone: string ("***-***-1234")
  - email: string
  - languageCode: string ("en" | "hi" | "es")
  - fontSizeScale: number (0.85 - 1.35)
  - highContrast: boolean
  - isAdmin: boolean
  - createdAt: timestamp

/users/{userId}/progress/{lessonId}
  - lessonId: string
  - lastCompletedStep: number
  - isCompleted: boolean
  - updatedAt: timestamp

/users/{userId}/bookmarks/{lessonId}
  - lessonId: string
  - bookmarkedAt: timestamp

/community_videos/{videoId}
  - title: string
  - description: string
  - category: string ("WhatsApp" | "QR Codes" | "Basics" | "Maps")
  - videoUrl: string (Storage bucket URL)
  - durationSeconds: number
  - uploaderId: string
  - uploaderName: string
  - helpfulCount: number
  - reportsCount: number
  - status: string ("pending" | "approved" | "rejected")
  - rejectionReason: string?
  - uploadDate: timestamp

/voice_groups/{groupId}
  - name: string
  - topic: string
  - description: string
  - creatorId: string
  - creatorName: string
  - iconCode: string
  - inviteCode: string
  - memberIds: array<string>
  - isPrivate: boolean
  - createdAt: timestamp

/voice_groups/{groupId}/messages/{messageId}
  - senderId: string
  - senderName: string
  - senderPhoneMasked: string
  - durationSeconds: number
  - audioUrl: string (Storage bucket URL)
  - waveform: array<number>
  - timestamp: timestamp

/moderation_reports/{reportId}
  - itemType: string ("video" | "voice_message")
  - itemId: string
  - titleOrSender: string
  - reason: string
  - reportedByUserId: string
  - isResolved: boolean
  - reportedAt: timestamp
```

## 4. Expected Hosting & Cloud Storage Costs (Google Cloud / Firebase)
- **Spark Plan (Free Tier):**
  - Authentication: 10,000 phone verifications/month (or free email/Google).
  - Firestore: 50,000 reads/day, 20,000 writes/day, 1 GB storage. (Sufficient for ~1,500 active elderly learners daily).
  - Storage: 5 GB cloud storage, 1 GB/day download bandwidth.
- **Blaze Plan (Pay as you grow):**
  - Storage: \$0.026 / GB / month.
  - Video streaming bandwidth: \$0.12 / GB network egress.
  - Estimated operating cost for 10,000 active seniors: ~\$15 - \$35 / month.

## 5. Deployment Instructions (When Connecting Real Project)
1. Run `flutterfire configure` to generate `lib/firebase_options.dart`.
2. Add `firebase_core: ^3.0.0` and `cloud_firestore: ^5.0.0` to `pubspec.yaml`.
3. Deploy security rules:
   ```bash
   firebase deploy --only firestore:rules,storage
   ```
4. The client service layer (`lib/services/`) automatically detects Firebase initialization and routes requests from local memory to Firestore.
