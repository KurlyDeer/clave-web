# Project: English Bridge (Hispanic Community)

## 1. Vision & Scope
* **Mission:** Take Hispanic learners from zero English to book-author fluency.
* **Target Audience:** Universal (Kids, Adults, Seniors).
* **Instruction Language:** Spanish (Primary) moving toward English (Immersive).

## 2. Tech Stack & Architecture
* **Frontend:** Flutter (Mobile & Web)
* **Backend:** Firebase (Auth, Database, Storage)
* **AI Engine:** Claude 3.5 Sonnet (Writing/Grammar), Whisper (Speech)
* **State Management:** Provider or Riverpod (Claude: always use Riverpod)

## 3. Universal Design Rules (CRITICAL)
* **Accessibility:** All buttons must be large (minimum 48px height) for seniors/kids.
* **Color Palette:** High contrast. Primary: #D35400 (Terracotta), Secondary: #2E86C1 (Deep Blue).
* **Typography:** Minimum font size 18pt. Switch to 24pt if 'Senior Mode' is active.
* **Tone:** Friendly, encouraging, and culturally proud. No "robotic" errors.

## 4. Development Commands
* **Run App:** `flutter run`
* **Build Web:** `flutter build web`
* **Test:** `flutter test`

## 5. Development Constraints
* Avoid using "False Friends" in UI (e.g., don't use 'Actualizar' if you mean 'To Actualize').
* Ensure all Strings are in a separate `l10n` folder for easy Spanish/English switching.