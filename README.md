# Mentally - Mental Health Flutter App

A comprehensive mental health application built with Flutter that provides mood tracking, AI consultation, community support, audio therapy, and journaling features to help users maintain their mental well-being.

## Authors

- **Kairos Abinaya Susanto**
- **William Theodorus Wijaya**

## About Mentally

Mentally is a mental health application designed to provide comprehensive support for users' psychological well-being. The app combines modern technology with evidence-based mental health practices to offer a holistic approach to mental wellness.

### Key Features

- **Mood Tracking**: Track daily moods with a 5-point scale system and visualize patterns over time
- **AI Consultation**: Get personalized mental health support through AI-powered conversations
- **Community Support**: Connect with others through a supportive community platform
- **Audio Therapy**: Access guided meditations, breathing exercises, and relaxation sounds
- **Journaling**: Write and reflect on thoughts and experiences
- **Analytics**: View mood trends and insights (feature removed as per user request)
- **Secure Authentication**: Firebase-powered user authentication and data protection

## Architecture

The app follows **Clean Architecture** principles with **BLoC (Business Logic Component)** pattern for state management:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants and configurations
│   ├── routing/            # App routing configuration
│   ├── services/           # Dependency injection
│   ├── theme/              # App theming
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── mood/               # Mood tracking
│   ├── community/          # Community features
│   ├── ai_chat/            # AI consultation
│   ├── audio/              # Audio therapy
│   ├── journal/            # Journaling
│   └── profile/            # User profile
├── shared/                 # Shared components
│   ├── models/             # Data models
│   ├── widgets/            # Reusable widgets
│   └── extensions/         # Extension methods
└── main.dart               # App entry point
```

## Getting Started

### Prerequisites

- **Flutter SDK**: >= 3.0.0
- **Dart SDK**: >= 3.8.0
- **Firebase Account**: For backend services
- **Android Studio / VS Code**: For development
- **Git**: For version control

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mentally
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable the following services:
     - Authentication (Email/Password, Google Sign-in)
     - Cloud Firestore
     - Firebase Storage
     - Analytics
     - Crashlytics
     - Cloud Messaging
   
4. **Configure Firebase**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```

5. **Add Firebase configuration files**
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

6. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```env
   GOOGLE_AI_API_KEY=your_google_ai_api_key_here
   ```

### 🏃‍♂️ Running the App

#### Development Mode
```bash
# Run on Android device/emulator
flutter run -d android
```

#### Production Build
```bash
# Build APK for Android
flutter build apk --release
```

## Database Structure

### Firestore Collections

#### Collection: `users`
User profile information stored after registration:

| Field        | Type    | Description                              |
|--------------|---------|------------------------------------------|
| uid          | string  | UID from Firebase Authentication         |
| name         | string  | User's full name                         |
| email        | string  | User's email address                     |
| createdAt    | string  | Account creation timestamp (ISO format)  |

#### Collection: `moods`
Daily mood tracking data:

| Field        | Type    | Description                              |
|--------------|---------|------------------------------------------|
| userId       | string  | Reference to user document               |
| moodType     | string  | Mood type (very_sad, sad, neutral, etc.) |
| intensity    | number  | Mood intensity (1-5 scale)               |
| notes        | string  | Optional user notes                      |
| createdAt    | string  | Mood entry timestamp                     |

#### Collection: `posts`
Community posts and interactions:

| Field        | Type    | Description                              |
|--------------|---------|------------------------------------------|
| userId       | string  | Post author's user ID                    |
| content      | string  | Post content                             |
| tags         | array   | Post hashtags                            |
| isAnonymous  | boolean | Whether post is anonymous                |
| likes        | array   | Array of user IDs who liked the post     |
| createdAt    | string  | Post creation timestamp                  |

#### Collection: `journals`
Personal journal entries:

| Field        | Type    | Description                              |
|--------------|---------|------------------------------------------|
| userId       | string  | Journal owner's user ID                  |
| title        | string  | Journal entry title                      |
| content      | string  | Journal entry content                    |
| mood         | string  | Associated mood                          |
| createdAt    | string  | Entry creation timestamp                 |

## Features Overview

### 1. Authentication System
- **Email/Password Registration & Login**
- **Google Sign-in Integration**
- **Secure Session Management**
- **Password Reset Functionality**

### 2. Mood Tracking
- **5-Point Mood Scale**: Very Sad (1) to Very Happy (5)
- **Visual Mood Selection**: Intuitive emoji-based interface
- **Mood History**: Track patterns over time
- **Notes & Context**: Add context to mood entries

### 3. AI Consultation
- **Powered by Google's Generative AI**
- **Personalized Conversations**
- **Mental Health Support**
- **Coping Strategies & Resources**

### 4. Community Platform
- **Anonymous Posting Option**
- **Hashtag Support**
- **Like System**
- **Post Management** (Delete own posts)

### 5. Audio Therapy
- **Guided Meditations**
- **Breathing Exercises**
- **Relaxation Sounds**
- **Playlist Management**
- **Favorites System**

### 6. Journaling
- **Private Journal Entries**
- **Mood Association**
- **Rich Text Support**
- **Search & Filter**

## Configuration

### Environment Variables
```env
# Google AI API Key for AI consultation
GOOGLE_AI_API_KEY=your_api_key_here

# Firebase configuration (auto-generated)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key
```

### Firebase Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Moods are private to users
    match /moods/{moodId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Posts are public for reading, users can only edit their own
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Journals are private to users
    match /journals/{journalId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## Dependencies

### Core Dependencies
- **flutter**: Flutter SDK
- **firebase_core**: Firebase core functionality
- **firebase_auth**: Authentication
- **cloud_firestore**: Database
- **firebase_storage**: File storage
- **firebase_analytics**: Analytics tracking
- **firebase_crashlytics**: Crash reporting
- **firebase_messaging**: Push notifications

### State Management
- **flutter_bloc**: BLoC pattern implementation
- **equatable**: Value equality
- **get_it**: Dependency injection
- **injectable**: Code generation for DI

### UI/UX
- **go_router**: Navigation
- **fl_chart**: Charts and graphs
- **cached_network_image**: Image caching
- **flutter_svg**: SVG support

### Audio Features
- **just_audio**: Audio playback
- **audio_session**: Audio session management
- **volume_controller**: Volume control

### AI Integration
- **google_generative_ai**: Google AI integration

### Utilities
- **shared_preferences**: Local storage
- **intl**: Internationalization
- **url_launcher**: URL handling
- **permission_handler**: Device permissions
- **connectivity_plus**: Network connectivity
