# 🔥 Firebase Backend Integration Guide for Travellooply

## Overview
This document provides comprehensive instructions for integrating Firebase backend services into the Travellooply app.

## Current Implementation Status

✅ **Implemented (Mock/Demo Mode)**:
- Authentication Service with mock user data
- Firestore Service with in-memory data storage
- Location Service with GPS tracking
- Real-time chat functionality
- Circle matching algorithm
- Event management system

🔧 **To Be Configured (Production)**:
- Firebase Authentication
- Cloud Firestore Database
- Firebase Storage
- Firebase Security Rules
- Real-time database synchronization

---

## Step 1: Firebase Project Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: **travellooply**
4. Enable Google Analytics (optional but recommended)
5. Create project

### 1.2 Enable Required Services
- ✅ **Authentication**: Enable Email/Password provider
- ✅ **Firestore Database**: Create in production mode
- ✅ **Storage**: Enable for profile pictures and media
- ✅ **Analytics**: Track user engagement

---

## Step 2: Android Configuration

### 2.1 Register Android App
1. In Firebase Console, click "Add app" → Android
2. Android package name: `com.travellooply.app` (must match app)
3. Download `google-services.json`
4. Place file in: `/android/app/google-services.json`

### 2.2 Update build.gradle
File: `android/build.gradle`
```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

File: `android/app/build.gradle`
```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## Step 3: Web Configuration

### 3.1 Register Web App
1. In Firebase Console, click "Add app" → Web
2. App nickname: **Travellooply Web**
3. Copy the Firebase configuration object

### 3.2 Create firebase_options.dart
Run FlutterFire CLI (recommended) or manually create:

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.travellooply.app',
  );
}
```

---

## Step 4: Initialize Firebase in App

### 4.1 Update main.dart
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const TravellooPlyApp());
}
```

---

## Step 5: Firestore Database Structure

### 5.1 Collections Schema

**users/** (Collection)
```json
{
  "userId": {
    "username": "string",
    "email": "string",
    "avatarUrl": "string?",
    "country": "string",
    "languages": ["string"],
    "travelIntent": "string",
    "preferences": ["string"],
    "socialVibe": "string",
    "trustScore": "number",
    "location": "GeoPoint",
    "isOnline": "boolean",
    "createdAt": "Timestamp",
    "lastSeen": "Timestamp",
    "isPremium": "boolean"
  }
}
```

**circles/** (Collection)
```json
{
  "circleId": {
    "activityType": "string",
    "memberIds": ["string"],
    "radius": "number",
    "centerLocation": "GeoPoint",
    "createdAt": "Timestamp",
    "expiresAt": "Timestamp",
    "status": "string",
    "creatorId": "string"
  }
}
```

**events/** (Collection)
```json
{
  "eventId": {
    "creatorId": "string",
    "type": "string",
    "description": "string",
    "maxParticipants": "number",
    "participantIds": ["string"],
    "startTime": "Timestamp",
    "endTime": "Timestamp",
    "location": "GeoPoint",
    "status": "string",
    "circleId": "string?"
  }
}
```

**messages/** (Collection)
```json
{
  "messageId": {
    "circleId": "string",
    "senderId": "string",
    "message": "string",
    "timestamp": "Timestamp",
    "expiresAt": "Timestamp"
  }
}
```

### 5.2 Create Indexes
Required composite indexes:
1. **circles**: `status (Ascending) + expiresAt (Ascending)`
2. **events**: `status (Ascending) + startTime (Ascending)`
3. **messages**: `circleId (Ascending) + timestamp (Descending)`

---

## Step 6: Security Rules

### 6.1 Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    
    // Circles collection
    match /circles/{circleId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
        request.auth.uid in resource.data.memberIds;
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.creatorId;
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
        request.auth.uid in resource.data.participantIds;
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.creatorId;
    }
    
    // Messages collection
    match /messages/{messageId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow delete: if isAuthenticated() && 
        request.auth.uid == resource.data.senderId;
    }
  }
}
```

### 6.2 Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/{filename} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /event_images/{eventId}/{filename} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Step 7: Update Service Files for Production

### 7.1 AuthService (lib/services/auth_service.dart)
Replace mock implementation with Firebase Auth:
```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> signUp({...}) async {
  try {
    // Create user with Firebase Auth
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Create user document in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'username': username,
      'email': email,
      // ... other fields
    });
    
    return true;
  } catch (e) {
    return false;
  }
}
```

### 7.2 FirestoreService (lib/services/firestore_service.dart)
Replace mock data with actual Firestore queries:
```dart
static Future<List<CircleModel>> getNearbyCircles({
  required GeoPoint userLocation,
  double radiusKm = 5.0,
}) async {
  // Use GeoFlutterFire or manual geo queries
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('circles')
      .where('status', isEqualTo: 'active')
      .get();
  
  return snapshot.docs
      .map((doc) => CircleModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ))
      .toList();
}
```

---

## Step 8: Testing

### 8.1 Development Testing
1. Use Firebase Emulator Suite for local testing
2. Test authentication flows
3. Verify Firestore operations
4. Test real-time updates

### 8.2 Production Deployment
1. Switch from test mode to production mode
2. Enable security rules
3. Set up monitoring and alerts
4. Configure backups

---

## Troubleshooting

### Common Issues:
1. **"No Firebase App '[DEFAULT]' created"**
   - Ensure Firebase.initializeApp() is called before runApp()
   - Verify firebase_options.dart exists and is imported

2. **Permission denied errors**
   - Check Firestore security rules
   - Verify user is authenticated
   - Ensure indexes are created

3. **Location not updating**
   - Grant location permissions in app settings
   - Check GPS is enabled on device
   - Verify geolocator configuration

---

## Resources
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Security Rules Guide](https://firebase.google.com/docs/rules)

---

**Note**: Current implementation uses mock data for demo purposes. Follow this guide to integrate actual Firebase services for production deployment.
