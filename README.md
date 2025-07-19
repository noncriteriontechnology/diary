# Lawyer's Diary - Flutter Frontend

A comprehensive mobile application for lawyers to manage clients, appointments, and notes with secure authentication and offline capabilities.

## Features

### 🔐 Authentication
- Secure user registration and login
- JWT token-based authentication
- Password validation and security
- Automatic token refresh

### 👥 Client Management
- Add, edit, and delete clients
- Comprehensive client profiles with contact information
- Case type categorization and priority levels
- Client search and filtering
- Quick call and WhatsApp integration
- Client notes and document management

### 📅 Appointment Scheduling
- Calendar view with monthly/weekly layouts
- Schedule, edit, and cancel appointments
- Appointment types and status tracking
- Conflict detection and validation
- Client-specific appointment history
- Recurring appointment support

### 📝 Notes Management
- Create text and voice notes
- Tag-based organization
- Priority levels and favorites
- Search and filter capabilities
- Client and appointment linking
- File attachments support

### 🎨 User Interface
- Material Design 3 theming
- Light and dark mode support
- Responsive layouts for all screen sizes
- Intuitive navigation with bottom tabs
- Search and filter functionality
- Loading states and error handling

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── client.dart
│   ├── appointment.dart
│   └── note.dart
├── services/                 # API and external services
│   └── api_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── client_provider.dart
│   ├── appointment_provider.dart
│   └── note_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── dashboard_screen.dart
│   ├── clients/
│   │   ├── clients_screen.dart
│   │   ├── client_detail_screen.dart
│   │   └── add_edit_client_screen.dart
│   ├── appointments/
│   │   └── appointments_screen.dart
│   └── notes/
│       └── notes_screen.dart
├── widgets/                  # Reusable UI components
└── utils/                    # Utilities and helpers
    └── app_theme.dart
```

## Dependencies

### Core Dependencies
- **flutter**: Flutter SDK
- **provider**: State management
- **dio**: HTTP client for API calls
- **shared_preferences**: Local storage
- **flutter_secure_storage**: Secure token storage

### UI Components
- **table_calendar**: Calendar widget
- **flutter_spinkit**: Loading animations
- **fluttertoast**: Toast notifications
- **image_picker**: Image selection

### Audio & Media
- **record**: Audio recording
- **audioplayers**: Audio playback
- **permission_handler**: Device permissions

### Communication
- **url_launcher**: Phone calls and WhatsApp
- **intl**: Date formatting and internationalization

## Installation

1. **Prerequisites**
   ```bash
   # Install Flutter SDK
   # Add Flutter to your PATH
   flutter doctor
   ```

2. **Clone and Setup**
   ```bash
   cd lawyers_diary/frontend
   flutter pub get
   ```

3. **Configuration**
   - Update API base URL in `lib/services/api_service.dart`
   - Configure backend server endpoint
   - Set up permissions in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`

4. **Run the App**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

## API Integration

The app communicates with a Node.js backend through RESTful APIs:

### Authentication Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update user profile

### Client Management
- `GET /api/clients` - List clients with pagination
- `POST /api/clients` - Create new client
- `GET /api/clients/:id` - Get client details
- `PUT /api/clients/:id` - Update client
- `DELETE /api/clients/:id` - Delete client

### Appointment Management
- `GET /api/appointments` - List appointments
- `POST /api/appointments` - Create appointment
- `GET /api/appointments/calendar` - Calendar view
- `PUT /api/appointments/:id` - Update appointment
- `DELETE /api/appointments/:id` - Delete appointment

### Notes Management
- `GET /api/notes` - List notes with search
- `POST /api/notes` - Create note with file upload
- `PUT /api/notes/:id` - Update note
- `DELETE /api/notes/:id` - Delete note

## State Management

The app uses Provider pattern for state management:

### AuthProvider
- User authentication state
- Login/logout functionality
- Token management
- User profile data

### ClientProvider
- Client list management
- CRUD operations
- Search and filtering
- Loading states

### AppointmentProvider
- Appointment scheduling
- Calendar data management
- Status updates
- Conflict detection

### NoteProvider
- Notes management
- Voice recording handling
- File attachments
- Search functionality

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record voice notes</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>
```

## Features Implementation Status

### ✅ Completed
- [x] User authentication (login/register)
- [x] Client management (CRUD operations)
- [x] Client detail view with tabs
- [x] Appointment calendar view
- [x] Notes management with search/filter
- [x] Material Design 3 theming
- [x] State management with Provider
- [x] API integration with error handling
- [x] Navigation and routing
- [x] Quick call and WhatsApp buttons

### 🚧 In Progress / TODO
- [ ] Voice recording implementation
- [ ] File attachment handling
- [ ] Offline mode with local storage
- [ ] Push notifications
- [ ] Advanced search functionality
- [ ] Data synchronization
- [ ] Performance optimizations
- [ ] Unit and integration tests

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Troubleshooting

### Common Issues

1. **API Connection Issues**
   - Verify backend server is running
   - Check API base URL configuration
   - Ensure network permissions are granted

2. **Permission Denied Errors**
   - Add required permissions to manifest files
   - Request runtime permissions for sensitive features

3. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions
   - Verify all dependencies are compatible

### Debug Commands
```bash
flutter doctor -v
flutter clean
flutter pub deps
flutter analyze
```

## Contributing

1. Follow Flutter/Dart style guidelines
2. Use meaningful commit messages
3. Test on both Android and iOS
4. Update documentation for new features
5. Ensure proper error handling

## License

This project is part of the Lawyer's Diary application suite.
