# Project Structure & Antigravity IDE Rules

> **Project Target**: `agorartcapptest` (Flutter Audio/Video Calling, RTM Chat & Notifications)  
> **Location**: `F:\AgoraRTCtestApp\agorartcapptest`  
> **Generated Date**: 2026-07-31  

---

## 1. Project Overview

`agorartcapptest` is a cross-platform Flutter application providing real-time voice & video calling (via Agora RTC Engine), 1-on-1 messaging (via Agora RTM Engine), and signaling via a FastAPI backend service.

### Key Technologies
- **SDK**: Flutter (Dart `^3.12.2`)
- **State Management**: `GetX` (`^4.7.2`)
- **Real-Time Communication**: `agora_rtc_engine` (`^6.3.2`) & `agora_rtm` (`^2.2.5`)
- **Persistence**: `shared_preferences` (`^2.2.3`)
- **Environment Management**: `flutter_dotenv` (`^5.2.1`)
- **Design System**: Material 3, Dark Mode (`AppColor`), `google_fonts` (Outfit)

---

## 2. Directory Structure Map

```
F:\AgoraRTCtestApp\agorartcapptest\
│
├── .agents/
│   └── AGENTS.md                   # Antigravity IDE agent workspace rules & guidelines
│
├── .env                            # Environment variables (API_BASE_URL, AGORA_APP_ID)
├── analysis_options.yaml           # Static analysis and linter rules
├── pubspec.yaml                    # Package dependencies and asset configurations
├── README.md                       # Flutter default README
├── implementation_documentation.md # System architecture & token generation technical spec
│
└── lib/
    ├── main.dart                   # Application entry point & dotenv loader
    ├── app.dart                    # GetMaterialApp configuration, theme, initial binding
    │
    ├── core/                       # Shared modules, services, and app-wide singletons
    │   ├── api_endpoint/
    │   │   └── api_endpoint.dart   # Centralized API endpoints & dotenv accessors
    │   ├── binding/
    │   │   └── controller_binder.dart # Central GetX dependency injection binder
    │   ├── common/
    │   │   └── widgets/            # Reusable UI widgets across features
    │   ├── constants/
    │   │   └── app_color.dart      # Application color palette & dark mode theme tokens
    │   └── services/
    │       ├── local_service/      # SharedPreferences storage helpers
    │       ├── network_service/    # HTTP client handlers and token headers
    │       └── rtm_service/        # Agora RTM signaling & messaging singleton service
    │
    ├── features/                   # Domain features (Clean Architecture pattern)
    │   ├── auth/                   # User authentication (Login, Register)
    │   │   ├── controllers/        # AuthController
    │   │   ├── models/             # UserModel, AuthResponse
    │   │   ├── screens/            # LoginScreen, RegisterScreen
    │   │   └── service/            # AuthService
    │   │
    │   ├── call/                   # Audio & Video calling domain
    │   │   ├── controllers/        # CallController (RTC Engine lifecycle & controls)
    │   │   ├── models/             # CallModel (channel, tokens, status)
    │   │   ├── screens/            # ActiveAudioCallScreen, ActiveVideoCallScreen, Outgoing/Incoming dialogs
    │   │   ├── service/            # CallService (Initiate, Accept, Reject, Poll calls)
    │   │   └── widgets/            # Diagnostic log overlay & control buttons
    │   │
    │   ├── chat/                   # Real-time 1-on-1 chat
    │   │   ├── controllers/        # ChatController
    │   │   ├── models/             # ChatMessageModel
    │   │   ├── screens/            # ChatScreen
    │   │   └── service/            # ChatService
    │   │
    │   ├── notification/           # Notification history & signaling events
    │   │   ├── controllers/        # NotificationController
    │   │   ├── models/             # NotificationModel
    │   │   ├── screens/            # NotificationScreen
    │   │   └── service/            # NotificationService
    │   │
    │   ├── profile/                # User profile settings & session details
    │   │   ├── controllers/        # ProfileController
    │   │   └── screens/            # ProfileScreen
    │   │
    │   ├── splash/                 # Startup splash screen & token verification
    │   │   ├── controllers/        # SplashController
    │   │   └── screens/            # SplashScreen
    │   │
    │   └── user_list/              # Active user directory for initiating calls/chats
    │       ├── controllers/        # UserListController
    │       ├── screens/            # UserListScreen
    │       └── service/            # UserListService
    │
    └── routes/
        └── app_routes.dart         # GetX named routes registry and GetPage routing table
```

---

## 3. Rules to Follow in Antigravity IDE

When working on or modifying this codebase in **Antigravity IDE**, follow these architecture and coding standards:

### Rule 1: Feature-First Clean Architecture
- Place code strictly in its designated feature directory (`lib/features/<feature>/`) or core utility (`lib/core/`).
- Each feature must maintain strict separation of concerns:
  - `controllers/`: State management & business logic (`GetxController`).
  - `models/`: Data classes & JSON serialization.
  - `screens/`: UI layout widgets (`StatelessWidget` / `Obx`).
  - `service/`: API endpoints and network call wrappers.

### Rule 2: GetX State Management Conventions
- **Controller Bindings**: Register app-wide singletons (`AuthController`, `CallController`, `NotificationController`, `RtmService`) in [controller_binder.dart](file:///F:/AgoraRTCtestApp/agorartcapptest/lib/core/binding/controller_binder.dart).
- **Reactive UI**: Use `.obs` for state variables and wrap consuming UI widgets in `Obx(() => ...)`.
- **Navigation**: Always use `Get.toNamed()`, `Get.offAllNamed()`, and `Get.back()`.

### Rule 3: Agora RTC & RTM SDK Constraints
- **Numeric UID Standard**: Agora RTC/RTM tokens MUST strictly use numeric (`int`) UIDs matching backend database user IDs.
- **Dynamic Token Selection**: Call screens must check whether the current user is the `caller` or `receiver` to apply the correct RTC token (`callerRtcToken` vs. `receiverRtcToken`).
- **Resource Lifecycle**: Always destroy RTC engine instances via `rtcEngine.leaveChannel()` and `rtcEngine.release()` when call screens exit to prevent background hardware lockups.

### Rule 4: API & Network Conventions
- **Centralized Endpoints**: Always fetch URLs from [api_endpoint.dart](file:///F:/AgoraRTCtestApp/agorartcapptest/lib/core/api_endpoint/api_endpoint.dart). Do not write raw URL strings in controllers or UI screens.
- **Environment Access**: Use `dotenv.env['KEY']` for environment variables.

### Rule 5: Code Quality & UI Tokens
- **Theme Consistency**: Use `AppColor` constants ([app_color.dart](file:///F:/AgoraRTCtestApp/agorartcapptest/lib/core/constants/app_color.dart)) and `GoogleFonts.outfit` for UI styling.
- **Linting Rules**: Comply with `flutter_lints` specified in [analysis_options.yaml](file:///F:/AgoraRTCtestApp/agorartcapptest/analysis_options.yaml).
