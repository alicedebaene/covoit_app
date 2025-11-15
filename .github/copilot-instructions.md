# Covoit App - AI Coding Assistant Instructions

## Project Overview
Covoit App is a Flutter carpooling application for campus-to-Friche transportation with integrated parking management. Users can be drivers (creating trips) or guards (scanning QR codes for parking access control).

## Architecture & Core Components

### Backend Integration
- **Supabase**: Primary backend service for auth, database, and real-time features
- **Global client**: Use `supabase` from `lib/service/supabase_client.dart` 
- **Authentication**: Handled via `AuthService` singleton (`authService`) in `lib/service/auth_services/auth_service.dart`

### Service Layer Pattern
Services are implemented as singletons with global instances:
- `authService` - Authentication operations
- `parkingService` - Parking data and availability
- Trip operations via `TripService` class (not singleton)

### Data Models
- `Trip`: Core entity with status flow: `reserve` → `au_parking` → `termine`
- `Parking`: Manages `placesDisponibles` counter for real-time availability
- Models use `fromMap()` factory constructors for Supabase response parsing

### User Roles & Navigation
Two distinct user flows after authentication:
- **Driver flow**: `lib/auth/screens/common/driver/` - Create trips, generate QR codes
- **Guard flow**: `lib/guard/` - Scan QR codes, monitor parking status

## Key Patterns & Conventions

### State Management
- Uses `setState()` pattern with loading/error states
- Common pattern: `loading` boolean + `error` string nullable fields
- Authentication state managed via Supabase `StreamBuilder<AuthState>`

### Error Handling
- Services throw `Exception` with French error messages
- UI displays errors using `Text` widget with `Colors.red`
- Always check `mounted` before calling `setState` in async operations

### UI Components
- `PrimaryButton`: Full-width elevated button with consistent padding
- `LoadingIndicator`: Centralized loading state component
- French language used throughout the UI

### QR Code Workflow
Critical business logic in `TripService.scanQr()`:
1. Token lookup in `trajets` table
2. Status-based actions (entry/exit from parking)
3. Atomic updates to both `trajets.statut` and `parking.places_disponibles`
4. Transaction logging in `scans` table

## Development Commands

```bash
# Run the app
flutter run

# Build for production
flutter build apk
flutter build ios

# Dependencies
flutter pub get
flutter pub upgrade
```

## File Organization
- `lib/service/` - Business logic and external service integration
- `lib/models/` - Data models with Supabase mapping
- `lib/widgets/` - Reusable UI components  
- `lib/auth/screens/` - Authentication and user role screens
- `lib/guard/` - Guard-specific functionality