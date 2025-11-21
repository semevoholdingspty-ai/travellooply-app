# 🌍 Travellooply - Dynamic Local Social Circles for Travelers

> **Connect with travelers nearby • Create instant social circles • Share amazing experiences**

![Travellooply](assets/icon/app_icon.png)

A Flutter mobile application that creates real-time, hyper-local, temporary social circles for travelers based on proximity, shared interests, and micro-events.

---

## 🚀 Quick Start

### Current Status: **Mock Mode** (Demo with Sample Data)

The app is currently running in **demo mode** with mock data. This allows you to explore all features without Firebase configuration.

To enable **real Firebase integration**, follow the [Firebase Integration Guide](FIREBASE_INTEGRATION_GUIDE.md).

---

## ✨ Features

### 🎯 Core Features
- ✅ **Dynamic Circle Matching**: Auto-group travelers by location, activity, and social vibe
- ✅ **Ephemeral Chats**: 24-hour auto-delete messaging
- ✅ **Micro-Events**: Quick 20-60 minute meetups
- ✅ **Location Tracking**: Real-time GPS proximity detection
- ✅ **Trust Score System**: Community-based reputation
- ✅ **Multi-Activity Support**: 10+ activity types

### 🎨 User Experience
- ✅ **Vibrant UI**: Energetic gradients and colorful design
- ✅ **Smooth Animations**: Polished transitions and effects
- ✅ **Onboarding Flow**: Welcome → Intent → Preferences → Social Vibe
- ✅ **Bottom Navigation**: Map, Circles, Events, Profile

### 🔥 Firebase Integration (Ready)
- ✅ **Authentication Service**: Email/password + OAuth ready
- ✅ **Firestore Database**: Real-time data synchronization
- ✅ **Location Services**: GPS tracking and geoqueries
- ✅ **Cloud Storage**: Profile pictures and media (ready)
- ✅ **Security Rules**: Production-ready templates

### 🎛️ Admin Dashboard
- ✅ **Web Interface**: Beautiful admin panel
- ✅ **User Management**: Monitor travelers and trust scores
- ✅ **Circle Oversight**: View active circles and members
- ✅ **Event Management**: Track micro-events
- ✅ **Analytics**: Real-time statistics

---

## 📱 Screens

### Onboarding
1. **Splash Screen** - Animated logo with gradient
2. **Welcome** - Get started with hero animation
3. **Travel Intent** - Select primary activity (6 cards)
4. **Activity Preferences** - Choose interests (10+ options)
5. **Social Vibe** - Pick personality type (3 options)

### Main App
1. **Map Radar** - Google Maps with circle markers and radius visualization
2. **Circles List** - Active nearby circles with real-time updates
3. **Circle Chat** - Ephemeral messaging (24h auto-delete)
4. **Events List** - Micro-events happening now
5. **Create Event** - Full event creation flow
6. **Profile** - Trust score, stats, and preferences

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.35.4
- **Language**: Dart 3.9.2
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **UI**: Material Design 3

### Backend (Ready for Integration)
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Hosting**: Firebase Hosting
- **Functions**: Cloud Functions (ready)

### Dependencies
```yaml
# Firebase (LOCKED versions)
firebase_core: 3.6.0
cloud_firestore: 5.4.3
firebase_auth: 5.3.1
firebase_storage: 12.3.2

# Location
google_maps_flutter: 2.10.0
geolocator: 13.0.2
geocoding: 3.0.0

# State & Storage
provider: 6.1.5+1
hive: 2.2.3
hive_flutter: 1.1.0
shared_preferences: 2.5.3

# UI & Utils
cached_network_image: 3.4.1
shimmer: 3.0.0
timeago: 3.7.0
```

---

## 🎯 Project Structure

```
lib/
├── constants/
│   └── app_constants.dart          # Colors, styles, configs
├── config/
│   └── firebase_config.dart        # Mock/Real Firebase toggle
├── models/
│   ├── user_model.dart
│   ├── circle_model.dart
│   ├── micro_event_model.dart
│   └── chat_message_model.dart
├── services/
│   ├── auth_service.dart           # Mock implementation
│   ├── auth_service_real.dart      # Production implementation
│   ├── firestore_service.dart      # Mock implementation
│   ├── firestore_service_real.dart # Production implementation
│   └── location_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding/                 # 4 onboarding screens
│   ├── home/                       # Map radar + home
│   ├── circles/                    # List + chat
│   ├── events/                     # List + create
│   └── profile/
├── firebase_options_template.dart  # Template for your config
└── main.dart

scripts/
├── configure_firebase.py           # Auto-configure Firebase
└── create_firestore_collections.py # Create sample data

docs/
├── FIREBASE_SETUP.md              # Original setup guide
└── FIREBASE_INTEGRATION_GUIDE.md  # Step-by-step integration
```

---

## 🔧 Setup & Installation

### Prerequisites
- Flutter SDK 3.35.4 or compatible
- Dart SDK 3.9.2 or compatible
- Android SDK (for APK builds)
- Firebase account (for production)

### Quick Start

1. **Clone or download the project**
   ```bash
   cd /home/user/flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run in demo mode (mock data)**
   ```bash
   flutter run -d chrome
   # or
   flutter build web --release
   ```

4. **Configure Firebase (for production)**
   - Follow [Firebase Integration Guide](FIREBASE_INTEGRATION_GUIDE.md)
   - Run `python3 scripts/configure_firebase.py`
   - Rebuild the app

---

## 🔥 Firebase Configuration

### Current Mode: **MOCK** (Demo Data)

To enable real Firebase:

1. **Complete Firebase Console setup** (5 min)
2. **Get configuration files** (3 min)
3. **Run configuration script** (1 min)
4. **Rebuild app** (2 min)

**Total time**: ~10 minutes

📖 **Detailed guide**: [FIREBASE_INTEGRATION_GUIDE.md](FIREBASE_INTEGRATION_GUIDE.md)

---

## 🎨 Design System

### Colors
- **Primary**: #1A73E8 (Travel Blue)
- **Accent**: #FF9F1C (Social Orange)
- **Background**: #F5F7FA
- **Text Primary**: #2B2B2B
- **Text Secondary**: #6F6F6F

### Activity Colors
Each of the 10 activities has a unique color:
- Explore: Purple (#9C27B0)
- Socialize: Deep Orange (#FF5722)
- Eat: Green (#4CAF50)
- Walk: Light Blue (#03A9F4)
- Nightlife: Deep Purple (#673AB7)
- Chill: Teal (#009688)
- Coffee: Brown (#795548)
- Photography: Orange (#FF9800)
- Museums: Blue Grey (#607D8B)
- Shopping: Pink (#E91E63)

### Typography
- **Font**: Inter (Bold, Regular, Semi-Bold)
- **Hierarchy**: 32/24/20/16/14/12px

---

## 📊 Data Models

### User
```dart
{
  id, username, email, avatarUrl, country, languages,
  travelIntent, preferences, socialVibe, trustScore,
  location (GeoPoint), isOnline, createdAt, isPremium
}
```

### Circle
```dart
{
  id, activityType, memberIds, radius, centerLocation,
  createdAt, expiresAt (24h), status, creatorId
}
```

### MicroEvent
```dart
{
  id, creatorId, type, description, maxParticipants,
  participantIds, startTime, endTime, location, status
}
```

### ChatMessage
```dart
{
  id, circleId, senderId, message, timestamp,
  expiresAt (24h auto-delete)
}
```

---

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart
```

### Test Coverage
- ✅ Widget tests for all screens
- ✅ Unit tests for services
- ✅ Integration tests for flows

---

## 🚀 Deployment

### Web Preview
```bash
flutter build web --release
python3 -m http.server 5060 --directory build/web
```

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Firebase Hosting
```bash
firebase deploy --only hosting
```

---

## 🎛️ Admin Dashboard

Access the admin panel at:
```
https://[your-app-url]/admin_dashboard.html
```

Features:
- 📊 Real-time statistics
- 👥 User management
- 🔵 Circle monitoring
- 📅 Event oversight
- 🔐 Security controls

---

## 📖 Documentation

- **[Firebase Setup Guide](FIREBASE_SETUP.md)** - Original comprehensive guide
- **[Firebase Integration Guide](FIREBASE_INTEGRATION_GUIDE.md)** - Step-by-step setup
- **[API Documentation](docs/API.md)** - Service layer docs (coming soon)
- **[Contributing Guide](CONTRIBUTING.md)** - Contribution guidelines (coming soon)

---

## 🐛 Known Issues & Limitations

### Current Limitations:
- ⚠️ Mock data in demo mode (not persistent)
- ⚠️ Google Maps requires API key for production
- ⚠️ Push notifications not yet implemented
- ⚠️ iOS build not tested (Android and Web only)

### Roadmap:
- 🔜 Push notifications for events
- 🔜 In-app messaging with image support
- 🔜 Advanced filters (premium)
- 🔜 Verified traveler badges
- 🔜 Multi-language support

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Google Maps for location services
- The open-source community

---

## 📞 Support

Need help? Have questions?
- 📖 Check [FIREBASE_INTEGRATION_GUIDE.md](FIREBASE_INTEGRATION_GUIDE.md)
- 🐛 Report issues on GitHub
- 💬 Join our community (coming soon)

---

## ⭐ Star History

If you find this project useful, please consider giving it a star! ⭐

---

**Built with ❤️ using Flutter • Made for travelers, by travelers**
