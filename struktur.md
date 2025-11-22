face_attendance_app/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── storage_constants.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   ├── date_utils.dart
│   │   │   ├── image_utils.dart
│   │   │   └── qr_utils.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── storage_service.dart
│   │   │   ├── face_recognition_service.dart
│   │   │   ├── camera_service.dart
│   │   │   └── qr_service.dart
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── course_model.dart
│   │   │   ├── class_model.dart
│   │   │   ├── attendance_model.dart
│   │   │   └── session_model.dart
│   │   └── widgets/
│   │       ├── custom_app_bar.dart
│   │       ├── custom_button.dart
│   │       ├── custom_text_field.dart
│   │       ├── loading_indicator.dart
│   │       ├── face_camera_widget.dart
│   │       └── qr_scanner_widget.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── login_page.dart
│   │   │   │   │   ├── register_page.dart
│   │   │   │   │   └── face_register_page.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── login_form.dart
│   │   │   │   │   └── role_selector.dart
│   │   │   │   └── providers/
│   │   │   │       └── auth_provider.dart
│   │   │   └── domain/
│   │   │       └── repositories/
│   │   │           └── auth_repository.dart
│   │   ├── admin/
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── admin_dashboard.dart
│   │   │   │   │   ├── course_management.dart
│   │   │   │   │   ├── class_management.dart
│   │   │   │   │   ├── user_management.dart
│   │   │   │   │   └── reports_page.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── course_form.dart
│   │   │   │   │   ├── class_form.dart
│   │   │   │   │   ├── user_form.dart
│   │   │   │   │   └── report_filters.dart
│   │   │   │   └── providers/
│   │   │   │       ├── admin_provider.dart
│   │   │   │       └── report_provider.dart
│   │   │   └── domain/
│   │   │       └── repositories/
│   │   │           └── admin_repository.dart
│   │   ├── dosen/
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── dosen_dashboard.dart
│   │   │   │   │   ├── start_session_page.dart
│   │   │   │   │   ├── attendance_management.dart
│   │   │   │   │   └── session_history.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── session_qr_display.dart
│   │   │   │   │   ├── attendance_list.dart
│   │   │   │   │   └── status_selector.dart
│   │   │   │   └── providers/
│   │   │   │       └── dosen_provider.dart
│   │   │   └── domain/
│   │   │       └── repositories/
│   │   │           └── dosen_repository.dart
│   │   ├── mahasiswa/
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── mahasiswa_dashboard.dart
│   │   │   │   │   ├── course_selection.dart
│   │   │   │   │   ├── qr_scan_page.dart
│   │   │   │   │   ├── attendance_history.dart
│   │   │   │   │   └── face_verification_page.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── course_card.dart
│   │   │   │   │   ├── attendance_card.dart
│   │   │   │   │   └── qr_scanner_overlay.dart
│   │   │   │   └── providers/
│   │   │   │       └── mahasiswa_provider.dart
│   │   │   └── domain/
│   │   │       └── repositories/
│   │   │           └── mahasiswa_repository.dart
│   │   └── profile/
│   │       ├── presentation/
│   │       │   ├── pages/
│   │       │   │   └── profile_page.dart
│   │       │   └── widgets/
│   │       │       └── profile_form.dart
│   │       └── domain/
│   │           └── repositories/
│   │               └── profile_repository.dart
│   ├── shared/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── colors.dart
│   │   │   └── text_styles.dart
│   │   ├── navigation/
│   │   │   ├── app_router.dart
│   │   │   ├── routes.dart
│   │   │   └── navigation_service.dart
│   │   └── state/
│   │       ├── app_provider.dart
│   │       └── user_provider.dart
│   └── main.dart
├── assets/
│   ├── images/
│   │   ├── icons/
│   │   │   ├── app_icon.png
│   │   │   ├── admin_icon.png
│   │   │   ├── dosen_icon.png
│   │   │   └── mahasiswa_icon.png
│   │   └── illustrations/
│   │       ├── login_illustration.png
│   │       ├── face_scan_illustration.png
│   │       └── qr_scan_illustration.png
│   ├── fonts/
│   │   ├── poppins/
│   │   └── inter/
│   └── config/
│       └── app_config.json
├── web/
├── test/
│   ├── widget_test.dart
│   └── app_test.dart
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── .gitignore