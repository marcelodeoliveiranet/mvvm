# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run the app
flutter analyze          # Static analysis (flutter_lints)
flutter test             # Run tests (none exist yet)
```

## Architecture

This is a Flutter MVVM app with Provider for state management. The codebase is in Portuguese (Brazilian).

### Layer Structure

**Domain** (`lib/domain/`) — Models/entities with `toJson()`/`fromJson()` serialization.

**Data** (`lib/data/`) — Services make HTTP calls via Dio; Repositories wrap service calls and return `Result<T>`. Repository interfaces are abstract classes with remote implementations (`*ImplRemote`).

**UI** (`lib/ui/`) — Each module (auth, user) has ViewModels (`ChangeNotifier`) and widgets. ViewModels use the **Command pattern** (`lib/utils/command.dart`) for async operations, which tracks `running`/`error`/`completed` states and prevents duplicate execution.

**Core** (`lib/core/`) — Network setup (Dio + `AuthInterceptor` for automatic token refresh on 401), local storage (`AuthStored` via SharedPreferences), and typed exception hierarchy (`AppException` → `HttpException`, `NetworkException`, etc.).

### Key Patterns

- **Result type** (`lib/utils/result.dart`): Sealed class (`Ok<T>` | `Failure<T>`) used instead of try-catch for error handling across repositories.
- **Command pattern** (`lib/utils/command.dart`): `Command0<T>` (no args) and `Command1<T, A>` (one arg) wrap async ViewModel actions. Used in widgets with `ListenableBuilder`.
- **DI**: Manual Provider tree in `lib/config/dependencies.dart` — Services → Repositories → ViewModels, all wired via `context.read()`.
- **Auth flow**: `AuthInterceptor` injects Bearer tokens, auto-refreshes on 401 using a separate Dio instance to avoid interceptor loops. On refresh failure, clears storage.
- **Routing**: GoRouter (`lib/routing/`) with auth redirect guard driven by `AuthViewModel.isLoggedIn`. Routes: `/login`, `/users`, `/user-form`.

### Configuration

API base URL is hardcoded in `lib/config/environment.dart`.
