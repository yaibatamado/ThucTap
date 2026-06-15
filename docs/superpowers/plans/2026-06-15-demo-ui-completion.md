# Demo UI Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the Flutter hospital app UI so reviewers can run it without a backend and inspect all core patient flows plus role overview screens.

**Architecture:** Keep `ApiClient` as the single API entrypoint and feed all offline data from `DemoApi`. Replace the older patient screens that still have broken text or incomplete flow with focused, theme-aware screens that parse demo data and navigate through realistic success/detail states.

**Tech Stack:** Flutter, Material 3, Provider, GoRouter, `http.Response` demo API responses.

---

### Task 1: Patient Appointment Flow

**Files:**
- Modify: `lib/screens/patient/lich_hen_bn_screen.dart`
- Create: `lib/screens/patient/lich_hen_detail_screen.dart`
- Modify: `lib/routes/app_router.dart`

- [ ] Replace the appointment screen with a clean form, appointment list, status chips, cancel action, and route to detail/QR.
- [ ] Add appointment detail screen for reviewing appointment status and payment action.
- [ ] Add route `/patient/lich/:maLich`.

### Task 2: Patient Lab Results

**Files:**
- Modify: `lib/screens/patient/ket_qua_xet_nghiem_screen.dart`
- Create: `lib/screens/patient/ket_qua_xet_nghiem_detail_screen.dart`
- Modify: `lib/routes/app_router.dart`

- [ ] Replace list screen with clean cards and empty/loading states.
- [ ] Add detail screen with result summary and status.
- [ ] Add route `/patient/xetnghiem/:maPhieuXN`.

### Task 3: Invoice and Payment Flow

**Files:**
- Modify: `lib/screens/patient/gio_hang_hoa_don_screen.dart`
- Modify: `lib/screens/patient/payment_qr_screen.dart`
- Create: `lib/screens/patient/payment_success_screen.dart`
- Create: `lib/screens/patient/hoa_don_detail_screen.dart`
- Modify: `lib/routes/app_router.dart`

- [ ] Replace invoice screen with cart, history, detail navigation, and payment CTA.
- [ ] Replace QR screen with theme-aware payment confirmation.
- [ ] Add payment success screen.
- [ ] Add invoice detail route `/patient/hoadon/:maHD`.
- [ ] Add payment success route `/patient/payment/success/:maLich`.

### Task 4: Demo Data and Role Polish

**Files:**
- Modify: `lib/services/demo_api.dart`
- Modify: `lib/screens/nhansu/tiepnhan_screens.dart`
- Modify: `README.md`

- [ ] Ensure demo data includes appointment, invoice, cart, test result, and user records used by the new screens.
- [ ] Replace the reception home placeholder with a usable dashboard.
- [ ] Document demo mode, role buttons, and real backend command.

### Task 5: Verification

**Files:**
- Test: `test/services/demo_api_test.dart`

- [ ] Run `dart format lib test docs`.
- [ ] Run `flutter test`.
- [ ] Run `flutter analyze --no-fatal-infos --no-fatal-warnings`.
- [ ] Run `flutter build apk --debug`.
