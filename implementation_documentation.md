# System Implementation Documentation

This document provides a technical walkthrough of the **Agora RTC Audio & Video Calling Architecture**, covering the Python/FastAPI backend service, the Web Dashboard (Agora Web SDK v4), and the Flutter Mobile Application (`agora_rtc_engine`).

---

## 1. System Architecture Overview

The system provides cross-platform real-time audio and video communication between mobile devices (Android/iOS) and web browsers.

```
┌─────────────────────────┐         ┌─────────────────────────┐
│   Flutter Mobile App    │         │  Web Dashboard (SDK v4) │
│ (agora_rtc_engine v6.x) │         │   (AgoraRTC_N-4.20.0)   │
└────────────┬────────────┘         └────────────┬────────────┘
             │                                   │
             │     REST API & Call Signaling     │
             └─────────────────┬─────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ FastAPI Backend     │
                    │ (agora-token-builder│
                    │   sqlite / JWT)     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Agora SD-RTN Edge   │
                    │   (RTC Gateway)     │
                    └─────────────────────┘
```

---

## 2. Backend Architecture (`F:\AgotaRTCtest`)

The backend is built with **FastAPI** and **SQLAlchemy**, running on Render at `https://agotartctestserver.onrender.com`.

### A. Authentication & User Management
- **Endpoints**: `POST /api/v1/auth/register`, `POST /api/v1/auth/login`, `GET /api/v1/auth/me`.
- **JWT Authorization**: Users log in and receive a JSON Web Token (`access_token`). Subsequent requests include `Authorization: Bearer <token>`.
- **User Discovery**: `GET /api/v1/users` lists active users and online statuses.

### B. Agora AccessToken Token Generation (`app/agora_utils.py`)
- **Package**: `agora-token-builder>=1.0.0`.
- **App ID**: `5d14aebdcf754f92a51247ee5f0bfed0`.
- **Primary Certificate**: `cb91ccc8a20d4620aef13c49e4fdc0ad`.
- **Token Spec**: AccessToken (v006) format with integer UID binding.

```python
from agora_token_builder import RtcTokenBuilder as PyRtcTokenBuilder

class RtcTokenBuilder:
    ROLE_PUBLISHER = 1
    ROLE_SUBSCRIBER = 2

    @classmethod
    def generate_rtc_token(cls, channel_name: str, uid: int, role: int = 1, expire_seconds: int = 3600) -> str:
        app_id = settings.AGORA_APP_ID
        app_certificate = settings.AGORA_PRIMARY_CERTIFICATE
        
        current_ts = int(time.time())
        privilege_expired_ts = current_ts + expire_seconds
        token_role = 1 if role == cls.ROLE_PUBLISHER else 2

        return PyRtcTokenBuilder.buildTokenWithUid(
            app_id,
            app_certificate,
            channel_name,
            uid,
            token_role,
            privilege_expired_ts
        )
```

### C. Call Signaling Flow (`app/routers/calls.py`)
1. **Initiate Call** (`POST /api/v1/calls/initiate`):
   - Generates a unique channel name: `call_<caller_id>_<receiver_id>_<timestamp>`.
   - Generates `caller_rtc_token` (bound to `caller_id` UID) and `receiver_rtc_token` (bound to `receiver_id` UID).
   - Stores call status as `initiated`.
   - Sends an in-app notification to the receiver containing the RTC tokens, call type (`audio` or `video`), and channel name.
2. **Accept / Reject Call** (`POST /api/v1/calls/status`):
   - Receiver updates call status to `accepted` or `rejected`.
3. **Poll Call Status** (`GET /api/v1/calls/history`):
   - Mobile and Web clients poll call status updates to sync connection state when the call is answered or terminated.

---

## 3. Web Dashboard Implementation (`F:\AgotaRTCtest\static\index.html`)

The Web Dashboard integrates the **Agora Web SDK v4 (`AgoraRTC`)** for in-browser media calling.

### Key Implementation Details
- **SDK Loader**: `https://download.agora.io/sdk/release/AgoraRTC_N-4.20.0.js`.
- **Client Initialization**:
  ```javascript
  agoraClient = AgoraRTC.createClient({ mode: "rtc", codec: "vp8" });
  ```
- **Track Management**:
  - `localAudioTrack = await AgoraRTC.createMicrophoneAudioTrack();`
  - `localVideoTrack = await AgoraRTC.createCameraVideoTrack();`
- **Publishing & Subscribing**:
  ```javascript
  // Subscribe to remote streams
  agoraClient.on("user-published", async (user, mediaType) => {
      await agoraClient.subscribe(user, mediaType);
      if (mediaType === "video") user.videoTrack.play("remoteVideo");
      if (mediaType === "audio") user.audioTrack.play();
  });

  // Join & Publish
  await agoraClient.join(appId, channelName, token, Number(uid));
  await agoraClient.publish([localAudioTrack, localVideoTrack]);
  ```
- **Live Video Elements**: Uses dedicated `#localVideo` and `#remoteVideo` grid containers to display local and remote camera feeds.

---

## 4. Flutter Mobile App Architecture (`F:\AgoraRTCtestApp\agorartcapptest`)

The Flutter application follows a **Feature-First Clean Architecture** with **GetX** state management.

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── api_endpoint/api_endpoint.dart
│   ├── binding/controller_binder.dart
│   ├── common/widgets/
│   ├── constants/app_color.dart
│   └── services/
│       ├── local_service/shared_preferences_helper.dart
│       └── network_service/network_service.dart
├── features/
│   ├── auth/
│   ├── user_list/
│   ├── chat/
│   ├── notification/
│   └── call/
│       ├── controllers/call_controller.dart
│       ├── models/call_model.dart
│       ├── service/call_service.dart
│       ├── screens/
│       │   ├── active_audio_call_screen.dart
│       │   ├── active_video_call_screen.dart
│       │   ├── incoming_call_dialog.dart
│       │   └── outgoing_call_screen.dart
│       └── widgets/
└── routes/app_routes.dart
```

### A. State Management & Lifecycle (`CallController.dart`)
- **Controller Setup**: Extends `GetxController` and registered via `ControllerBinder`.
- **Engine Initialization**:
  ```dart
  rtcEngine = createAgoraRtcEngine();
  await rtcEngine!.initialize(const RtcEngineContext(
    appId: ApiEndpoint.agoraAppId,
    channelProfile: ChannelProfileType.channelProfileCommunication,
  ));
  ```
- **Media Controls**:
  - `toggleMute()`: Toggles microphone mute via `rtcEngine.muteLocalAudioStream(isMuted.value)`.
  - `toggleSpeaker()`: Toggles speakerphone mode via `rtcEngine.setEnableSpeakerphone(isSpeakerOn.value)`.
  - `switchCamera()`: Flips between front and back cameras via `rtcEngine.switchCamera()`.

### B. Dynamic Token Selection
`CallController` extracts the appropriate token based on the user's role:
```dart
String _getRtcToken(CallModel call, int myId) {
  if (call.callerId == myId) {
    return call.callerRtcToken ?? '';
  } else {
    return call.receiverRtcToken ?? '';
  }
}
```

### C. Video Call Screen (`active_video_call_screen.dart`)
- Uses `AgoraVideoView` with `VideoViewController` for rendering local camera feed.
- Uses `AgoraVideoView` with `VideoViewController.remote` bound to `remoteUid` when the partner joins the channel.
- Includes a live in-app diagnostic log overlay to monitor connection state, stream status, and token validation in real time.

---

## 5. Root Cause & Technical Resolution of `invalid token, authorized failed`

### Problem Summary
During initial testing, clients encountered `AgoraRTCError CAN_NOT_GET_GATEWAY_SERVER: invalid token, authorized failed` (Error 110).

### Root Causes Identified
1. **Custom Binary Packing Mismatch**: Hand-rolled packing logic in Python placed privileges before/after fields out of standard order, causing HMAC-SHA256 signature mismatch.
2. **UID Type Mismatch**: Tokens generated for String UIDs (`UserAccount`) were passed to `client.join` as Integer UIDs, which Agora Gateway rejects.

### Resolution Steps Applied
1. **Adopted Official `agora-token-builder`**: Updated `f:\AgotaRTCtest\app\agora_utils.py` to use `agora-token-builder` PyPI package.
2. **Unified Integer UIDs**: Standardized all token generation and `joinChannel` calls to use numeric user IDs (`int`) across Web and Mobile.
3. **Verified Cross-Platform Token Acceptance**: Validated backend token output against official Node.js `agora-token` parser and live WebRTC Gateway connections.
