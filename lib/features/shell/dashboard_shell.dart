import 'dart:ui' show ImageFilter;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../data/services/services.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import '../../widgets/form_fields.dart' show appMenuItemStyle;
import '../../widgets/lucide_icon.dart';
import 'left_sidebar.dart';
import '../offline/offline_runtime.dart';

/// ZSL content languages shown in the top bar (en / te / hi only),
/// port of `langu()` in DashboardLayout.vue.
final zslLanguagesProvider = FutureProvider<List<AppLanguage>>((ref) async {
  final body = await ref
      .read(activityTrackingServiceProvider)
      .getZslLanguages();
  const allowed = {'en', 'te', 'hi'};
  final langs = unwrapList(body)
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .where((l) => allowed.contains((asString(l['code']) ?? '').toLowerCase()))
      .map(AppLanguage.fromJson)
      .toList();
  if (langs.isNotEmpty) {
    final current = ref.read(sessionProvider).language;
    if (!langs.any((l) => l.code == current.code)) {
      ref.read(sessionProvider.notifier).setLanguage(langs.first);
    }
  }
  return langs;
});

/// `text-gray-800 dark:text-white` of the top bar.
Color _navText(BuildContext context) =>
    context.isDark ? Colors.white : Tw.gray800;

/// Port of `src/components/DashboardLayout.vue` (+ LeftSidebar + Footer).
class DashboardShell extends ConsumerWidget {
  const DashboardShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = context.isMd;
    final learning = ref.watch(offlineWorkspaceOwnerProvider) != null;
    // The layout's own `isDark` is `colorMode === 'dark'`, so in "system"
    // mode it keeps the light background (and image) even when the OS — and
    // so every `dark:` class inside — is dark. Kept as on the web.
    final layoutDark = ref.watch(colorModeProvider) == ColorModePref.dark;

    return Scaffold(
      backgroundColor: layoutDark
          ? AppColors.dashboardDark
          : AppColors.dashboardLight,
      bottomNavigationBar: wide || learning
          ? null
          : MobileBottomNav(location: location),
      body: Container(
        decoration: layoutDark
            ? null
            : const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/dashboard_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
        child: SafeArea(
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide && !learning) LeftSidebarRail(location: location),
              Expanded(
                child: Column(
                  children: [
                    if (!learning) const _TopBar(),
                    // The scroll area's `md:pb-6` (below md its `pb-24` only
                    // clears the fixed bottom bar, which doesn't overlap here).
                    Expanded(
                      key: const ValueKey('dashboard-page-content'),
                      child: _MainText(
                        child: wide
                            ? Padding(
                                padding: EdgeInsets.only(
                                  bottom: learning ? 0 : 24,
                                ),
                                child: child,
                              )
                            : child,
                      ),
                    ),
                    // Below 768px the fixed bottom bar (h-16, z-40) covers the
                    // footer completely on the web.
                    if (wide && !learning) const AppFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `<main class="text-gray-900 dark:text-white">`: the default text colour
/// of every eLabs page (dialogs keep the body's `--foreground`).
class _MainText extends StatelessWidget {
  const _MainText({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.isDark ? Colors.white : Tw.gray900;
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(bodyColor: color, displayColor: color),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: color),
        child: child,
      ),
    );
  }
}

/// `<nav class="flex flex-wrap justify-between items-center gap-4 min-h-14
/// px-2">` (the template's `xs:px-4` doesn't exist in Tailwind v4).
class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final daysLeft = _daysUntilExpiry(session.expiresOn);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            if (session.role == Role.institute &&
                daysLeft != null &&
                daysLeft <= 3)
              _ExpiryBadge(daysLeft: daysLeft),
            const Spacer(),
            const _LanguageSelect(),
            const SizedBox(width: 8),
            const _ColorModeButton(),
            const SizedBox(width: 8),
            const _UserMenu(),
          ],
        ),
      ),
    );
  }

  static int? _daysUntilExpiry(String? expiresOn) {
    if (expiresOn == null || expiresOn.isEmpty) return null;
    final expiry = DateTime.tryParse(expiresOn);
    if (expiry == null) return null;
    final diffMs = expiry.difference(DateTime.now()).inMilliseconds;
    return (diffMs / Duration.millisecondsPerDay).ceil();
  }
}

/// `px-2 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-600
/// dark:bg-red-900 dark:text-red-300 animate-pulse`.
class _ExpiryBadge extends StatefulWidget {
  const _ExpiryBadge({required this.daysLeft});
  final int daysLeft;

  @override
  State<_ExpiryBadge> createState() => _ExpiryBadgeState();
}

class _ExpiryBadgeState extends State<_ExpiryBadge>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
    lowerBound: 0.5,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.daysLeft;
    final text = d > 0
        ? 'Expires in $d day${d == 1 ? '' : 's'}'
        : d == 0
        ? 'Expires today'
        : 'Expired';
    final dark = context.isDark;
    final fg = dark ? Tw.red300 : Tw.red600;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _pulse,
        curve: const Cubic(0.4, 0, 0.6, 1),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: dark ? Tw.red900 : Tw.red100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(BootstrapIcons.clock_history, size: 12, color: fg),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The language `<Select>`: the trigger's `h-7` loses to the kit's
/// `data-[size=default]:h-9`, so it is 36px tall, `w-14 sm:w-16 px-1 gap-1
/// text-xs`, with `bi-translate text-lg`, the 2-letter code and the chevron.
/// Content `max-h-[40vh]`, items `py-1` with a translate icon.
class _LanguageSelect extends ConsumerStatefulWidget {
  const _LanguageSelect();

  @override
  ConsumerState<_LanguageSelect> createState() => _LanguageSelectState();
}

class _LanguageSelectState extends ConsumerState<_LanguageSelect> {
  final _menu = MenuController();
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final langs =
        ref.watch(zslLanguagesProvider).valueOrNull ?? const <AppLanguage>[];
    final current = ref.watch(sessionProvider.select((s) => s.language));
    final code =
        (langs.any((l) => l.code == current.code) ? current.code : 'LA')
            .toUpperCase();
    final dark = context.isDark;
    final input = context.inputColor;
    final fg = _navText(context);
    final itemStyle = appMenuItemStyle(context).copyWith(
      minimumSize: const WidgetStatePropertyAll(Size(0, 28)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );

    return MenuAnchor(
      controller: _menu,
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        minimumSize: const WidgetStatePropertyAll(Size(128, 0)),
        maximumSize: WidgetStatePropertyAll(
          Size(320, MediaQuery.sizeOf(context).height * 0.4),
        ),
      ),
      menuChildren: [
        for (final l in langs)
          MenuItemButton(
            style: itemStyle,
            onPressed: () => ref.read(sessionProvider.notifier).setLanguage(l),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(BootstrapIcons.translate, size: 14),
                const SizedBox(width: 8),
                Text(l.name),
                const SizedBox(width: 10),
                SizedBox.square(
                  dimension: 14,
                  child: l.code == current.code
                      ? OverflowBox(
                          maxWidth: 16,
                          maxHeight: 16,
                          child: LucideIcon(
                            Lucide.check,
                            size: 16,
                            color: context.mutedFgColor,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
      ],
      builder: (context, controller, _) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: context.isSm ? 64 : 56,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: dark
                  ? input.withValues(alpha: _hover ? 0.5 : 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: input),
              boxShadow: AppShadows.xs,
            ),
            child: Row(
              children: [
                Icon(BootstrapIcons.translate, size: 18, color: fg),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    code.length > 2 ? code.substring(0, 2) : code,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 12, height: 16 / 12, color: fg),
                  ),
                ),
                LucideIcon(
                  Lucide.chevronDown,
                  size: 16,
                  color: context.mutedFgColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `p-2 rounded-full hover:bg-indigo-50 dark:hover:bg-indigo-950/40` with
/// the sun / moon / laptop icon (`text-base`), cycling light → dark →
/// system, and the shadcn tooltip (`bg-primary text-primary-foreground
/// rounded-md px-3 py-1.5 text-xs`, no delay).
class _ColorModeButton extends ConsumerStatefulWidget {
  const _ColorModeButton();

  @override
  ConsumerState<_ColorModeButton> createState() => _ColorModeButtonState();
}

class _ColorModeButtonState extends ConsumerState<_ColorModeButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(colorModeProvider);
    final (icon, color, label) = switch (mode) {
      ColorModePref.light => (
        BootstrapIcons.sun_fill,
        Tw.yellow500,
        'Light Mode',
      ),
      ColorModePref.dark => (BootstrapIcons.moon_fill, Tw.blue500, 'Dark Mode'),
      ColorModePref.system => (
        BootstrapIcons.laptop,
        Tw.gray500,
        'System Mode',
      ),
    };
    final dark = context.isDark;
    return Tooltip(
      message: label,
      waitDuration: Duration.zero,
      preferBelow: true,
      verticalOffset: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      textStyle: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        color: context.colors.onPrimary,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => ref.read(colorModeProvider.notifier).cycle(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            // 16px glyph on a 24px line + p-2 → 32×40.
            width: 32,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hover
                  ? (dark ? Tw.indigo950.withValues(alpha: 0.4) : Tw.indigo50)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}

enum _UserAction { name, profile, upgrade, logout }

/// The user `<DropdownMenu>`: trigger `flex items-center gap-2 p-2
/// rounded-full` with the bold upper-case name (≥640px) and
/// `bi-person-circle text-xl`; content aligned to the trigger with roomy
/// touch targets for the profile actions.
class _UserMenu extends ConsumerStatefulWidget {
  const _UserMenu();

  @override
  ConsumerState<_UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends ConsumerState<_UserMenu> {
  final _menu = MenuController();
  final _triggerKey = GlobalKey();
  double _triggerWidth = 208;
  bool _hover = false;

  Future<void> _onSelected(_UserAction a) async {
    switch (a) {
      case _UserAction.name:
        break;
      case _UserAction.profile:
        context.go('/MyProfile');
      case _UserAction.upgrade:
        context.go('/upgradeplan');
      case _UserAction.logout:
        await ref.read(sessionProvider.notifier).logout();
        AppToast.success('Logged out successfully!');
        if (mounted) context.go(AppRoutes.loginPath);
    }
  }

  void _toggle() {
    if (_menu.isOpen) {
      _menu.close();
      return;
    }
    final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    setState(() => _triggerWidth = box?.size.width ?? 208);
    _menu.open();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final name = session.username.toUpperCase();
    final role = session.role;
    final dark = context.isDark;
    final sm = context.isSm;
    final fg = _navText(context);
    final style = appMenuItemStyle(context);

    MenuItemButton item(
      _UserAction a,
      IconData icon,
      String label, {
      Color? iconColor,
    }) => MenuItemButton(
      style: style.copyWith(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 16, height: 22 / 16),
        ),
      ),
      onPressed: () => _onSelected(a),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 20, child: Icon(icon, size: 18, color: iconColor)),
          const SizedBox(width: 14),
          Text(label),
        ],
      ),
    );

    return MenuAnchor(
      controller: _menu,
      // align="end", sideOffset 4.
      alignmentOffset: Offset(_triggerWidth - 208, 8),
      style: const MenuStyle(
        minimumSize: WidgetStatePropertyAll(Size(208, 0)),
        maximumSize: WidgetStatePropertyAll(Size(208, double.infinity)),
      ),
      menuChildren: [
        if (!sm)
          MenuItemButton(
            style: style.copyWith(
              minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            overflowAxis: Axis.vertical,
            onPressed: () => _onSelected(_UserAction.name),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (role != Role.admin)
          item(_UserAction.profile, BootstrapIcons.person_fill, 'Profile'),
        if (role == Role.institute)
          item(
            _UserAction.upgrade,
            BootstrapIcons.arrow_up_circle,
            'Upgrade Plan',
          ),
        if (role != Role.admin)
          // `bg-border -mx-1 my-1 h-px`
          SizedBox(
            height: 13,
            child: OverflowBox(
              minWidth: 208,
              maxWidth: 208,
              child: Container(height: 1, color: context.borderColor),
            ),
          ),
        item(
          _UserAction.logout,
          BootstrapIcons.box_arrow_right,
          'Logout',
          iconColor: Tw.red500,
        ),
      ],
      builder: (context, controller, _) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            key: _triggerKey,
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _hover
                  ? (dark ? Tw.indigo950.withValues(alpha: 0.4) : Tw.indigo50)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: SizedBox(
              height: 28,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sm) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        name,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.isMd ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(BootstrapIcons.person_circle, size: 20, color: fg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Port of `src/components/Footer.vue`: `py-1 md:py-3 px-1
/// text-[8px] sm:text-sm md:text-xs tracking-wide bg-(--sidebar-bg)
/// backdrop-blur-lg border-t border-white/20`. Below 640px two lines
/// (`leading-5`), above one.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final textColor = dark ? Colors.white : const Color(0xFF333333);
    final dim = TextStyle(color: textColor.withValues(alpha: 0.8));
    const brand = TextStyle(
      color: AppColors.brandOrange,
      fontWeight: FontWeight.w700,
    );
    final sm = context.isSm;
    final md = context.isMd;
    // text-[8px] (line 20 from leading-5) / sm:text-sm (20) / md:text-xs (16)
    final fontSize = md ? 12.0 : (sm ? 14.0 : 8.0);
    final lineHeight = md ? 16.0 : 20.0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: md ? 12 : 4, horizontal: 4),
          decoration: BoxDecoration(
            color: dark ? AppColors.sidebarBg : Colors.transparent,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: fontSize,
              height: lineHeight / fontSize,
              letterSpacing: 0.025 * fontSize,
            ),
            textAlign: TextAlign.center,
            child: sm
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Powered by', style: dim),
                        const TextSpan(text: ' ZeroScienceLab ', style: brand),
                        TextSpan(
                          text: 'Fall in love with Mathematics & Science',
                          style: dim,
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Powered by', style: dim),
                            const TextSpan(
                              text: ' ZeroScienceLab',
                              style: brand,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Fall in love with Mathematics & Science',
                        style: dim,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
