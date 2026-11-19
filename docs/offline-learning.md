# Offline learning — Classes 7, 8, 9 and 10

The Windows/native Flutter app bundles 70 Math and 49 Science activities copied from `D:/new-elab-app`. Provider mapping IDs are matched locally. Only activities returned for the signed-in account and matching this registry can be installed. Some chapters have no native activity; activities without a matching native widget are skipped during preparation.

## Backend prerequisite

The backend at `D:/new-elab-backend` contains the offline API and an **unrun** migration. No migration was executed during this implementation. Package download and synchronization return HTTP 503 until those tables are deployed separately. The forwarding scheduler/queue worker must also be running for provider confirmation of quizzes and completions. See that repository's `docs/offline-learning-api.md`.

## User flow and testing

1. Log in online. Login does not prepare content automatically.
2. Select **Prepare for offline use** in the app banner. The centered dialog shows assigned classes and content language. Start preparation explicitly; the dialog closes and the job continues while using the app. Once installed, the banner offers **Learn offline** and **Update offline content**. Learning offline explicitly selects the local catalog even when connected. Update refreshes the saved roster and supporting files. Only API activities with a native widget in this app can be installed; an assigned class can still have no supported activities.
3. Disconnect the internet or stop the backend. The banner says **You’re offline** and offers **Learn offline**. This opens the normal Library (or MathZoro Math Zone), not a separate offline library.
4. Use the normal Library, Math Zone or Science Zone filters. Their curriculum responses come from the account-scoped, unexpired prepared SQLite packages for the current language. Unprepared classes/chapters do not appear offline. Bundled Dart activities are not downloaded.
5. Launch a prepared activity through its normal route. The native player loads prepared supporting material and quizzes, records progress locally, and keeps the local session alive if connectivity returns. Streaming videos still require internet.
6. Lab admins use presentation/practice mode and the saved class/batch/student roster. Only prepared assigned classes containing that activity are offered. Activity records retain the selected student identity. Local records are not a user-facing tab.
7. Close and reopen the app while disconnected, retaining the signed-in session. Prepared activities and saved results remain available until package expiry.
8. Reconnect on any screen. Saved records upload automatically. The runtime checks curriculum availability through the configured backend every 5 seconds and on app resume. A localhost health response alone does not establish content-provider availability. Verify reports/provider confirmation; repeated reconnects must not duplicate records.

There is no separate Offline Learning sidebar item, download-activities button, or manual sync action. The legacy `/offline` route redirects to the normal learning screen. Library/zone route state reloads when connectivity changes; an active local player stays local until it is left.

Background preparation and sync run while the app process is alive. They are not an operating-system download service after the app has been terminated. An interrupted preparation resumes when the user clicks Prepare again.

## Storage and behavior

- SQLite (`elab_offline.sqlite`) and encrypted supporting files live in the app's application support directory. Content, rosters, drafts, attempts and upload records are scoped to backend, institute and authenticated user. Signing out does not delete another account's saved work; a different login cannot view it through the app.
- The app needs an initial online login and online package preparation. Access expires at the backend-supplied package expiry; refresh the package online to renew it.
- Preparation defaults to the current content language, including Telugu. Choosing another preparation language also selects that language for browsing, so the installed package is visible. Catalog screens refresh after package installation and language changes. Preparation endpoints always contact the configured backend, including while curriculum browsing is using local storage.
- Offline class names come from the API package manifest. Published batch status is used for both online and saved offline rosters. Student class visibility follows active published-batch assignments rather than a hardcoded display-grade filter.
- Preparation also embeds thumbnail image fields for activities, topics, subjects, and chapters. The shared image widget reads saved data images directly from memory. Complete chapter metadata and syllabus suffixes are retained; long filter labels expose their full text in a tooltip.
- Offline quizzes use the online quiz component with local draft/attempt persistence. Answer-key-backed choices show immediate correctness and explanations. When the provider supplies no answer key, choices are saved without inventing a result and remain pending grading after synchronization.
- Active network-interface addresses (including Wi-Fi and Ethernet) are checked every two seconds to detect adapter changes. Internet/content availability is still verified through the content endpoint; a successful local backend request alone does not establish that online content is available.
- Supporting tabs use the online HTML viewer with saved inline styles and embedded images. Local HTML disables scripts and remote resources. Externally hosted styles, streaming videos, and other resources not included in the saved package still require online access.
- The offline player uses a compact learning workspace with dashboard navigation, footer, and preparation banner hidden while open. Activities, quizzes, and supporting documents use the remaining viewport instead of fixed-height document frames. Focus view hides learning controls and lab-admin selectors temporarily; exiting restores them without resetting progress or student selection.
- Downloaded material is verified by size and SHA-256 before opening. Installation is transactional. Interrupted downloads retain completed files for resuming.
- Event UUIDs and session sequence numbers are saved before uploading. Failed connections retain the original payload for retry. A lab admin's selected student is captured at activity start, including during teardown and delayed saves.
- Supporting images, text/HTML and PDFs are stored locally. Images embedded in guide/quiz HTML are saved as data images inside the encrypted snapshot. Streaming video is labelled **Internet required**; only a permitted video file explicitly supplied by the provider can play offline. The client never extracts or downloads a streaming platform's video.
- Payloads containing content, rosters, drafts, attempts and results use AES-256-GCM authenticated encryption. Supporting files and resumable download snapshots are encrypted too. The key is stored using Flutter Secure Storage (platform Keychain/Keystore/Windows protected storage). Existing plaintext payloads/files are upgraded on first access. SQLite's structural metadata, IDs and status columns remain readable; this is payload encryption, not whole-database SQLCipher.
- Images and HTML are decrypted for display in memory. Native PDF/video viewers require a temporary decrypted file while previewing; the viewer removes it after closing. A forced crash can leave a temporary preview file. Encryption protects persistent storage, but cannot make content impossible to extract while the app is displaying it.
- Native Dart activity code and bundled audio remain normal installed app assets.
- `pending` records still need upload. `uploaded`/`sending` await provider confirmation. `uncertain` requires backend reconciliation and is never automatically resubmitted. Rejected records are retained with an error. Server receipts are saved in SQLite.
- This feature targets the native app. Flutter Web requires a separate browser storage/file implementation.

## Automated checks

`flutter test test/prepared_catalog_test.dart test/offline_learning_banner_test.dart test/offline_runtime_test.dart test/offline_learning_test.dart test/lab_practice_test.dart --concurrency=1`

Backend tests use isolated in-memory SQLite, not the configured development database.

## Class 8 bundled content

Class 8 imports use the registries from D:/new-elab-app-8: 74 mathematics and 65 science mapping entries, backed by 137 distinct native activity widgets. The source maps two pairs of IDs to shared widgets; those mappings are preserved. All 23 referenced sounds are bundled under assets/audio/class8/ and verified against the source files. Only activities returned by the authorized class package are shown.

## Class 7 bundled content

Imported from D:/new-elab-app-7: 89 maths and 65 science mapping entries, backed by 152 distinct activity widgets. Source mappings that share a widget are preserved. All 66 source sound files are bundled under assets/audio/class7/, including filenames chosen dynamically by the science sound enums. Each copied sound has the same SHA-256 as its source. Mapping 2326 (BioDigital hormonal regulation anatomy models) requires internet and is deliberately excluded from offline preparation; its online availability is unchanged. One decorative network texture uses the existing bundled offline texture instead.

Class 7 emotional-development mappings 2320 and 2324 are pending four source assets: assets/images/ch6_a4_avatar_default.jpg, ch6_a4_avatar_neutral.jpg, ch6_a4_avatar_happy.jpg and ch6_a4_avatar_very_sad.jpg. They are absent from the provided source, so the activity source is retained as .dart.pending-assets and not registered offline. Restore the images, the source .dart extension and registry entries together before re-enabling it.
