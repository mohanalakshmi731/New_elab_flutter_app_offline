# Porting plan & conventions

Source: `d:\Tedlance\new-elab-web-app` (Vue 3 + Pinia + Tailwind/shadcn, ~90K lines).
All routed screens of both web routers are ported (status 2026-11-12). Routes live in
`lib/router/app_router.dart` (`_page(path, builder)` inside the eLabs / MathZoro shells).
Unrouted web files (`classlist_test.vue`, `InstructorBuilUpload.vue`, `metting.vue`) were skipped.

## Phases

| Phase | Scope | Status |
|---|---|---|
| **1 — Foundation** | Project for Windows/macOS/Android/iOS, env & flavors, API client (axios interceptors), all services (19 files, 199 methods), session store (setUserInfo/logout, persisted), theme (light/dark/system), router + guards, realtime (Echo/Reverb), WebView, loader, eLabs login + forgot/reset password, eLabs shell (sidebar rail / mobile bottom bar / top bar / footer), eLabs dashboard (all roles), MathZoro login + class-change screen (`/classchange`) + `/newlayout` shell + student dashboard | ✅ done |
| 2 — Users, institutes & plans | `userlist`, `usercreate`, `UserActivityLog`, `UserProfile` (`/MyProfile`), `Institutelist`, `Institutecreate`, `InstituteplanList/Create/Update`, `Zslplan`, `Zslplanlist`, `subscription`, `invitationlist`, `planwisestudentlist`, `Upgradeplan`, `signup`, `selfsignup` | ✅ done — code in `features/{users,institutes,plans,signup,upgrade}`; not yet exercised against the live API |
| 3 — Classes & courses | `classlist` (5.6K lines), `classcreate`, `ClassCourseCreate`, `batchlist`, `instructorlist`, `coursecreate`, `courselist`, `teachercoursepage`, `InstructorBuilUpload` (Echo import progress — not referenced by any route or component, so not ported), Tiptap → `HtmlEditor` | ✅ done — `features/{classes,courses,class_course,teacher,batches}`; not yet exercised against the live API |
| 4 — Schedules & live classes | `schedules` (5.8K lines, Echo presence/chat), `scheduleexam*`, `recordings`, `teacherschedules`, `teachersdashboardpage`, Zoom → `openZoomMeeting` | ✅ done — `features/{schedules,teacher_schedules,teacher_dashboard,zoom}`; Zoom opens in the Zoom app/browser (no embedded SDK: no in-meeting recording controls, hosts join via the join link); not yet exercised against the live API |
| 5 — Exams & question bank | `exam`, `ExamsList`, `examcreate`, `createquestion`, `EditExams`, `ViewExams`, `ExamAttempts`, `ExamResults`, `startexam`, `questionslist`, `QuizExam`, `newexams`, `newquestions`, proctoring | ✅ done — `features/{exams,new_exams,questions,new_questions,exam_manage,take_exam}`; proctoring captures the camera in a WebView page (`take_exam/proctor_camera_html.dart`) with the AI/warning logic in Dart; not yet exercised against the live API or a real camera |
| 6 — Library, math & science zones | `library`, `activitylibrary`, `elabsmathzone`, `elabssciencezone`, `mathplay`, `classmath`, `mathzoroquiz`, `newlibrarypage`, `studentsciencezone`, `studentactivitypage`, `studentpayment`, `studentdashbaordlayout` | ✅ done — `features/{library,zones,math_play,student_activity,student_science_zone,student_payment,student_dashboard_layout,quiz}`; not yet exercised against the live API |
| 7 — MathZoro student screens | `studentmathzone`, `playzone`, `studentreports`, profile / activity / payment inside `/newlayout` | ✅ done — `features/{mathzoro_zone,play_zone,student_reports}` + the shared student activity/payment pages under `/newlayout`; not yet exercised against the live API |

`src/pages/class/classlist_test.vue` is a scratch copy of `classlist.vue` and is not routed — skip it.

### Web updates synced

The web repo was pulled from `1758c0f` to `c50d492` during Phase 1 (2026-11-11), so the
Phase 1 files were re-checked against `c50d492` on 2026-11-12:

- **New screen** `src/pages/library/ActivityReports.vue` → `features/activity_reports`, route
  `/activityreport` (eLabs shell). Class / batch / subject / chapter filters and a per-student
  star table from `zslService.getQuizPerformance`.
- **eLabs sidebar** (`LeftSidebar.vue`): Exams, Question Bank and Schedules for every role but
  admin; Activity Reports for instructor/institute; theme button removed from the rail (the
  top bar keeps its light/dark/system button).
- **MathZoro shell** (`newdashboardlayout.vue`): no longer the LeftSidebar rail/bottom bar but
  its own collapsible sidebar (ZSL logo; ≥1024 px beside the content, below that a drawer
  behind ☰); hidden on the upgrade-plan page.
- Everything else in Phase 1 had only formatting changes. Store changes (exam list/attempt
  unwrapping, `batchRequestId`, `class_level`, autopilot link) were already in the later phases.

To check for newer web changes: `git -C <web repo> log --oneline c50d492..origin/dev`.

## How web concepts map to Flutter

| Web | Flutter |
|---|---|
| `useUserStore()` session fields (`userInfo`, `studentLoginData`, `batchDetails`, `language`…) | `ref.watch(sessionProvider)` / `ref.read(sessionProvider.notifier)` |
| Other Pinia state/actions | A Riverpod `Notifier` per feature (`lib/features/<area>/<area>_controller.dart`) that calls the services. Port the action body 1:1 (same id derivations from `userInfo`). |
| `src/service/x.ts` → `xService.method()` | `ref.read(xServiceProvider).method()` — same method names; returns the response **body** (axios `res.data`). Doc comments flag the few TS methods that returned the whole AxiosResponse. |
| axios interceptor toasts | Automatic in `ApiClient`. Don't re-toast API errors in screens. Use `silent: true` for polling. |
| `toast.success/error` | `AppToast.success/error` |
| `<Loader :loading>` | `LoadingOverlay(loading: …, child: …)` |
| `router.push('/x')` / `this.$route.query` | `context.go('/x')` (`context.push` for detail pages) / `GoRouterState.of(context).uri.queryParameters` |
| `<iframe :src>` / `v-html` content in an iframe | `WebContentView(url: …)` / `WebContentView(html: …)` |
| `window.open(url)` / `location.href = url` | `openExternal(url)`; Zoom: `openZoomMeeting(joinUrl:, meetingNumber:, password:)` |
| `new FormData()` + `File` | `Map<String, dynamic>` + `UploadFile` → `api.postMultipart` (services already do this) |
| `responseType: 'blob'` | `api.getBytes` → save with a file picker / share sheet |
| `this.$echo.private(ch).listen('.update', cb)` | `ref.read(echoClientProvider).private(ch).listen('.update', cb)` — cancel the subscription and `leave(ch)` in `dispose()` |
| `setInterval` / `clearInterval` | `Timer.periodic` started in `initState`, cancelled in `dispose` |
| Tailwind colours (`text-slate-400`, `bg-indigo-600/10`) | `Tw.slate400`, `Tw.indigo600.withValues(alpha: 0.1)` |
| `dark:` variants | `context.isDark ? … : …` |
| `sm:` / `md:` / `lg:` | `context.isSm` (640) / `context.isMd` (768) / `context.isLg` (1024) |
| `bi bi-house-door` | `BootstrapIcons.house_door` |
| Card `bg-white dark:bg-[#161e36] rounded-[24px] border shadow-md` | `SurfaceCard` |
| `.glass-card` | `GlassCard`, `GlassTextField` |
| chart.js / unovis | `fl_chart` (see `features/dashboard/dashboard_page.dart`) |
| Tiptap editor (`<Tiptap v-model>`) | `HtmlEditor(initialHtml:, onChanged:, controller:)` — a self-contained editor page (`assets/editor/editor.html`) in a WebView with the Tiptap toolbar; HTML in/out. (`flutter_quill` ≥ 11.5.1 needs Dart 3.12, and older 11.x conflicts with `flutter_secure_storage` 11 over `win32`.) |
| shadcn `<Button variant size>` | `AppButton(variant:, size:, loading:)` |
| `<Input>` / `<Textarea>` / `<Select>` / `<Input type="date">` in `<FormItem>` | `AppTextField`, `AppSelect<T>`, `AppDateField` (`YYYY-MM-DD` string), `FieldLabel` / `LabeledField` |
| `<Table>` in `<Card class="p-0 overflow-x-auto">` + skeleton rows + "No data" | `AppTable(columns:, rows:, loading:)` |
| `<Pagination>` with `visiblePages()` | `AppPagination(meta: PageMeta, onPageChanged:)`; Laravel paginator → `PageMeta.find(body)` |
| `<Dialog>` / delete confirmation | `showAppDialog` + `AppDialogFrame`; `showConfirmDialog(message:)` |
| `<Skeleton>` | `Skeleton(width:, height:)` |
| `<input type="file">` / blob download | `pickImageFile()` / `pickUploadFile(allowedExtensions:)` → `UploadFile`; `saveBytesAs(bytes, name)` |
| store `countries` / `states` / `dailCodes` | `countriesProvider` / `statesProvider` / `dialCodesProvider` (`features/common/lookups.dart`) |
| `sessionStorage` / `encrypt-storage` | controller state; persist with `secureStoreProvider` when it must survive restarts |

## Checklist per screen

1. Read the Vue file and the store actions it maps (`mapState`/`mapActions`).
2. Port the actions into the feature controller (or reuse an existing one).
3. Rebuild the template with the widgets above, keeping texts, colours, dark mode and breakpoints.
4. Replace the `_Pending` route with the real screen.
5. `flutter analyze` clean; add unit tests for any non-trivial logic (`test/`).

## Web bugs deliberately kept (decide: fix in the app, or keep matching the web)

The port copies the web's behaviour, including these bugs. Each is a small, local fix.

| Screen | Bug |
|---|---|
| Teacher course page / course list / class course create | Opening a course doesn't set `course_id`, so section/chapter/concept edits can target the previously opened course. "Add Chapter" uses the last *opened* section, not the row clicked. Opening an edit dialog refetches the course and the open section then lists every chapter. "Course Instructor" shows N/A after attach/preview. |
| Teacher course page | Updating a course sends empty `zsl_class_id`/`zone`/`curriculum_id` and `is_math_zoro` from `is_math_play`. |
| Class list | Toggling a class's status or clicking Edit can switch into that class's detail view. Instructor "Next" always requests page 2. Promote dialog keeps the previous target batches. Searching instructors doesn't filter the table. |
| Batch list (`/instructorlist`) | Paging calls a method the page never maps (no-op); trash icon has no handler. |
| Class access types (`/zslplanlist`) | Update dialog reads `full_access` but create sends `has_full_access` → saving can untick "Full Access Plan". |
| Subscription plan update | Only the first class gets its full ZSL plan list; `fetchZslPlansByClass` uses institute id `1`. |
| Create institute | Validation errors are computed but never shown. |
| Profile | "Zoom Enabled" switch knob never moves. |
| Schedules (`/schedules`) | Batch filter sends only the first character of the batch id (`form.batch[0]` on a string → batch 12 sends "1"). This Week/This Month batch change reloads without a date range. Presence channels from previously opened schedules are never left, so their chat keeps arriving. "Next Month" = month of today + 4 weeks. |
| Teacher schedules | Edit Schedule doesn't send Start Date/Subject. Same "Next Month" and presence-channel issues. |
| Teacher dashboard | "Today's Classes" always 0 (`getSchedules` returns nothing); GO LIVE / Open Visual Tool buttons do nothing; some stats are hard-coded. |
| Schedule exam (quiz) | Only rule 1 of section 1 filters questions; edit mode restores only the first rule. |
| Start exam | Phones/portrait tablets get terminated: the 900×560 minimum window check flags `WINDOW_TOO_SMALL` (same on the web's mobile browsers). An exam with no `duration_minutes` auto-submits immediately. Going offline terminates the exam. Any Cmd shortcut (incl. copy/paste) is a violation on macOS. |
| Exam create / edit exam | `exam_subject_id` compared against the wrong field (usually dropped); schedule (open anytime / start-end) never sent; first rule of each section hidden; rule trash deletes the previous rule; `show_results_to_student_at` loses underscores (`AFTER_EXAM` → `AFTEREXAM`); edit exam never sends start/end. |
| Questions | Creating a question never saves its tags (only update does). |
| Library / activity library | `/activitylibrary` opened without a selected activity (e.g. a direct nav link) stays on "Loading activity..." forever. "Show all Activities" compares chapter ids strictly. A failed signed URL is cached as empty until the page is reopened. Activity tracking every 5 s toasts any `message` it returns. |
| Student activity page | Back goes to `returnPath`; the science zone sets `/newlayout/newsciencezone`, which doesn't exist → "Page not found". An `xpChannel` message shows a debug alert. |
| eLabs Math/Science Zone | Students may see no stars/progress until their first quiz (`subjectPerformance` not unwrapped on first load). Class name can show "Select a Class" when the persisted id is a string. |
| Student payment | Removing a referral code doesn't reset the discount (total stays discounted, order created without the code). Referral check sends `platform: 'web'`. MathZoro shell "Upgrade Plan" for non-MathZoro students goes to `/studentpayment` (route name, not path → blank page on the web, "Page not found" in the app). |
| Student reports | Date ranges use UTC (`toISOString`), so in IST every range starts a day early. |
| Activity reports | With one class and "All Subjects", a course without a ZSL class/subject mapping fails the whole report ("needs a valid ZSL class and subject mapping") while the chapter list just skips it. With "All Classes", a `/batch` response nested one level deeper adds an "Unnamed Batch" (id `undefined`). Two subjects sharing a chapter id: the chapter belongs to the last one. Filter-loading errors show "Request failed with status code N" instead of the API message. |
| eLabs sidebar | Students also get Exams / Question Bank / Schedules (the web adds them for every role but admin); on phones the bottom bar holds 9–10 items, so labels truncate. |
| MathZoro shell nav | Student nav links to `/newlayout/studentdashboardlayout`, which neither web router defines. Staff avatar is a hard-coded `i.pravatar.cc` image. The "Appearance" icon is always the sun. On the upgrade-plan page only the header's user menu is left for navigation. |
| MathZoro Math Zone | Back button shows for non-MathZoro users and goes to `/newlayout/teachersdashboardpage`, which doesn't exist. Non-math subjects switch to "science" styling while the title still says "Math Zone". |
| MathZoro Play Zone | Quiz button and level filter are `hidden` on the web (the quiz handler calls an undefined store), so they're not ported. |
| Several | Some tables/dropdowns (`bg-gray-100`, `bg-white`) have no dark-mode variant and are hard to read in dark mode. Fields marked `*` are often not validated client-side. |

## Deliberate fixes of web bugs (the exception to "keep the web's behaviour")

- `/classmath`: the web declares `filteredChapters` under `methods`, so its template always shows "No chapters yet". The app renders the chapter map as intended.
- Shared LMS hand-off state (`lmsHandoffProvider`) is cleared on logout, matching the web store reset.

## UI/UX parity pass (2026-11-12)

Every screen was compared with its web template (and the child components and global `src/style.css`
rules it uses) and restyled to match in light and dark mode. Logic and APIs were not changed. Keep
these web facts in mind when adding or changing screens:

| Web fact | Flutter |
|---|---|
| `--primary` is #4f46e5, `--accent` (hover) #f49148. Tailwind's own `indigo-600` is the v4 value #4f39f6, a different colour. | `AppColors.primary`, `context.*Color` helpers |
| The web runs Tailwind **4.1** (oklch palette). | `Tw` is the v4 palette. Don't add local v3 hex palettes. |
| The theme overrides radii: `rounded-xl` 20, `rounded-lg` 16, `rounded-md` 14; bare `rounded` is 4. A radius larger than half the box makes it a circle (CSS clamps). | literal radii |
| The theme's `--shadow-*` values are much lighter than Tailwind's defaults, and coloured modifiers (`shadow-cyan-500/30`) have no effect. | `AppShadows.xs…xl2`, `cssShadow()` for arbitrary values |
| A CSS `drop-shadow()` / `blur()` value is the Gaussian's **standard deviation**, not a box-shadow blur radius. | `ImageFilter.blur(sigma = value)`; `Shadow.blurRadius = (value − 0.5) / 0.57735` |
| Global rules in `style.css`: `thead th` → primary background with primary-foreground text; `table .bi` → 18px icons; `ul { margin-left: 2rem }`. They override the templates' own classes. | `AppTable` follows them; local tables must too |
| The shadcn kit's classes often win over the page's: `<Select>` trigger is 36px (`data-[size=default]:h-9` beats `h-10`), and `<Button>` keeps `h-9`. Textareas use `field-sizing-content`: they start 64px tall and grow, and `rows` has no effect. | `AppSelect`, `AppButton`, `AppTextField` defaults |
| Not defined in this web build, so they do nothing: `font-urbanist`, `animate-slide-up`, the `xs:` breakpoint, and `prose` (no typography plugin, so `v-html` content is preflight-reset 16px/1.5 text). | ignore them |
| Tailwind 4 buttons have the default arrow cursor (no `cursor-pointer` in the kit). | see "Open decisions" below |
| Toasts are top-right; success #28883f, error #ff000d. A few calls set their own background. | `AppToast.success(msg, background: …)` |

Shared widget additions from this pass: `AppSelectItem.message(...)` (the web's plain centred note row in a
dropdown, e.g. "No batches available"), `AppToast.success(background:)`, and the optional parameters listed
in `lib/widgets` doc comments (`AppButton` hover colours/sizes, `AppSelect` sizes/colours/`menuLabel`,
`AppDialogFrame` background/radius/shadow/mobile layout, `AppTable` font size/empty text, `HtmlEditor`
`autoHeight`/`margin`).

### Visual differences left on purpose

- **Backdrop blur:** frosted-glass `backdrop-blur` on large panels and cards is skipped where the layer
  behind is opaque or nearly so, because it is expensive to repaint every frame in Flutter.
- **Native controls:** browser controls are approximated:
  - the date and time pickers use Flutter's dialogs;
  - number inputs have no spinner arrows;
  - textareas have no resize handle;
  - `title` tooltips are Flutter tooltips.
- **Tables:**
  - columns use fixed ratios with a minimum width before sideways scrolling, where the web sizes them to
    their unwrapped content;
  - `AppTable` rounds its header's corners, while the web card shows a square header over the rounded border.
- **Embedded HTML:** content in a WebView needs a fixed height where the web sizes it to the content. This
  affects the chapter reference dialogs (60% of the screen or 480px).
- **Window-wide overlays:** a few overlays that are `fixed` across the whole web window sit inside the page
  area instead: the student payment summary column, the upgrade plan's bottom bar, and the library sidebar's
  dark overlay.
- **Fonts and colour blending:**
  - Fredoka One is drawn as Fredoka at weight 600;
  - gradients blend in sRGB, not oklab;
  - the Chart.js tooltip colour boxes and carets aren't drawn.
- **Search on Enter:** `AppSearchBar` searches on Enter, while some web search boxes have no Enter handler.

### Open decisions

- **Cursor:**
  - The web shows the arrow cursor on most buttons (Tailwind 4 default).
  - The app shows the hand cursor on the shared buttons and dropdowns. Zones, student activity, plans,
    institutes and users switched their own plain buttons to the arrow.
  - Pick one for the whole app: matching the web means changing `AppButton`, `AppSelect` and similar
    widgets to `SystemMouseCursors.basic`.
- **`/classmath`:** it opens scrolled to START. On the web the map never renders (see "Deliberate fixes"),
  so there is no web behaviour to copy.

## Follow-ups (code health)

- `EchoClient` has no presence `here/joining/leaving` callbacks; `features/schedules/schedules_realtime.dart` and `features/teacher_schedules` each rebuild them from the raw `pusher:*` events. Move one implementation into `core/realtime/echo_client.dart`.
- Several feature-local widgets are general enough for `lib/widgets/` (ShadCard, FormGrid, MultiSelectField, FilePickField, SectionTabs, PasswordInput, FileInputField, and `LibrarySelect` / `HoverLift` / `DashedBox`, now used across features).
- `ColorMode.toggleLightDark()` (`lib/state/providers.dart`) has no callers since the sidebar's theme button was removed.
- Several screens now draw the web's inline SVG icons from their path data, and each has its own small SVG
  path parser: `zones/zone_widgets.dart`, `student_science_zone/science_zone_logic.dart` (`svgPath`),
  `mathzoro_zone/mz_zone_ui.dart` (`zoneSvgPath`) and `math_play/math_play_ui.dart`. Merge them into one in
  `lib/widgets`. `classes/quizsys_pdf.dart`'s `parseSvgPathData` misreads compact arc flags (`a2 2 0 012-2`).
- Local look-alikes of shared widgets exist where the shared one lacked an option:
  - dropdowns: `LibrarySelect`, `ReportSelect` (activity reports), and the signup selects;
  - tables: `PlanDataTable` (one full-width skeleton bar, square header corners);
  - the institute list's own pagination.
  
  Adding those options to `AppSelect` / `AppTable` / `AppPagination` would let them go.
- Unused after the parity pass: `TwShadow` in `upgrade/upgrade_plan_widgets.dart`, and the v3 `Mz` palette
  in `mathzoro/mz_ui.dart`, which math play no longer uses.
