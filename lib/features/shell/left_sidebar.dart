import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../state/providers.dart';
import 'nav_items.dart';

/// Clicks inside the rail / bottom bar and their fly-outs don't count as
/// "outside" (the web's `handleClickOutside` checks both refs).
const _navTapGroup = 'left-sidebar';

/// `transition: all .2s cubic-bezier(0.34, 1.56, 0.64, 1)` (enter).
const _overshoot = Cubic(0.34, 1.56, 0.64, 1);

/// The web's `src/assets/elabsLogo.png` (falls back to `logo.png`).
const _sidebarLogo = 'assets/images/elabs_sidebar_logo.png';

/// Desktop/tablet icon rail — port of the `<aside>` in LeftSidebar.vue:
/// `w-[72px] my-4 ml-4 mr-2 py-6 bg-white/95 dark:bg-slate-900/95 border
/// rounded-[28px] shadow-lg dark:shadow-none`, logo + dots on top, the menu
/// centred in the rest (`my-auto`, `gap-3 px-2.5`).
class LeftSidebarRail extends ConsumerStatefulWidget {
  const LeftSidebarRail({super.key, required this.location});
  final String location;

  @override
  ConsumerState<LeftSidebarRail> createState() => _LeftSidebarRailState();
}

class _LeftSidebarRailState extends ConsumerState<LeftSidebarRail> {
  /// `activeDropdown`
  String? _open;

  void _close() {
    if (_open != null) setState(() => _open = null);
  }

  @override
  void didUpdateWidget(covariant LeftSidebarRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    // navigateTo / navigateToChild reset the dropdown.
    if (oldWidget.location != widget.location) _open = null;
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final items = sidebarItemsFor(ref.watch(sessionProvider.select((s) => s.role)));

    return TapRegion(
      groupId: _navTapGroup,
      onTapOutside: (_) => _close(),
      child: Container(
        width: 72,
        margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: (dark ? Tw.slate900 : Colors.white).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
          // `shadow-lg shadow-slate-100/5 dark:shadow-none`
          boxShadow: dark ? null : AppShadows.lg,
        ),
        child: Column(
          children: [
            // Logo branding (`flex-col items-center gap-1 py-1`).
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go('/dashboard'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      Image.asset(
                        _sidebarLogo,
                        width: 48,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            Image.asset('assets/images/logo.png', width: 48, height: 32, fit: BoxFit.contain),
                      ),
                      // gap-1 + mt-1.5
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Dot(Tw.amber400),
                          SizedBox(width: 2),
                          _Dot(Tw.indigo400),
                          SizedBox(width: 2),
                          _Dot(Tw.indigo600),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _RailItem(
                          item: items[i],
                          location: widget.location,
                          open: _open == items[i].key,
                          onToggle: () => setState(() => _open = _open == items[i].key ? null : items[i].key),
                          onNavigate: (route) {
                            setState(() => _open = null);
                            context.go(route);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // The theme toggle that sat at the bottom of the rail is commented
            // out on the web; the top bar's light/dark/system button remains.
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

/// One rail button (`w-full h-11 rounded-2xl`, icon `text-xl`) with its
/// hover tooltip and, for items with children, the fly-out to the right.
class _RailItem extends StatefulWidget {
  const _RailItem({
    required this.item,
    required this.location,
    required this.open,
    required this.onToggle,
    required this.onNavigate,
  });

  final NavItem item;
  final String location;
  final bool open;
  final VoidCallback onToggle;
  final ValueChanged<String> onNavigate;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _tooltip = OverlayPortalController();
  final _dropdown = OverlayPortalController();
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 150),
    value: widget.open ? 1 : 0,
  );
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _tooltip.show();
    _dropdown.show();
  }

  @override
  void didUpdateWidget(covariant _RailItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) widget.open ? _anim.forward() : _anim.reverse();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final dark = context.isDark;
    final active = item.isActive(widget.location);
    final hasChildren = item.children.isNotEmpty;
    final iconColor = active
        ? (dark ? Tw.indigo400 : Tw.indigo600)
        : _hover
            ? (dark ? Colors.white : Tw.slate900)
            : (dark ? Tw.slate500 : Tw.slate400);
    final bg = active
        ? (dark ? Tw.indigo500.withValues(alpha: 0.2) : Tw.indigo600.withValues(alpha: 0.1))
        : _hover
            ? (dark ? Tw.slate800.withValues(alpha: 0.4) : Tw.slate50)
            : Colors.transparent;

    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: hasChildren ? widget.onToggle : () => widget.onNavigate(item.route!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 44,
          width: double.infinity,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active ? AppShadows.sm : null,
          ),
          child: Stack(
            children: [
              Center(child: Icon(item.icon, size: 20, color: iconColor)),
              // Tiny indicator dot for the open dropdown.
              if (widget.open)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Tw.indigo500,
                      shape: BoxShape.circle,
                      border: Border.all(color: dark ? Tw.slate900 : Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    Widget follower({required Widget child, double dx = 0, double scale = 1}) => Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.centerRight,
            followerAnchor: Alignment.centerLeft,
            offset: Offset(12 + dx, 0),
            child: Transform.scale(scale: scale, alignment: Alignment.centerLeft, child: child),
          ),
        );

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _tooltip,
        // `bg-slate-900 text-white text-[11px] font-bold py-1.5 px-3
        // rounded-lg shadow-md`, fades in on hover, hidden while open.
        overlayChildBuilder: (_) => follower(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _hover && !widget.open ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Tw.slate900,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppShadows.md,
                ),
                child: Text(
                  item.label,
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, height: 1.5),
                ),
              ),
            ),
          ),
        ),
        child: !hasChildren
            ? button
            : OverlayPortal(
                controller: _dropdown,
                overlayChildBuilder: (_) => AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) {
                    if (_anim.isDismissed) return const SizedBox.shrink();
                    final forward = _anim.status == AnimationStatus.forward || _anim.isCompleted;
                    final t = (forward ? _overshoot : Curves.easeIn).transform(_anim.value);
                    return follower(
                      dx: 8 * (1 - t),
                      scale: 0.95 + 0.05 * t,
                      child: Opacity(
                        opacity: _anim.value,
                        child: TapRegion(
                          groupId: _navTapGroup,
                          child: _NavFlyout(
                            item: item,
                            location: widget.location,
                            onNavigate: widget.onNavigate,
                            minWidth: 220,
                            padding: 8,
                            gap: 4,
                            childPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            childWeight: FontWeight.w600,
                            shadow: AppShadows.xl,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                child: button,
              ),
      ),
    );
  }
}

/// The dropdown list of child routes: `bg-white dark:bg-slate-900 border
/// rounded-2xl` with `rounded-xl text-xs` rows (active `bg-indigo-50
/// text-indigo-600 font-extrabold`).
class _NavFlyout extends StatelessWidget {
  const _NavFlyout({
    required this.item,
    required this.location,
    required this.onNavigate,
    required this.minWidth,
    required this.padding,
    required this.gap,
    required this.childPadding,
    required this.childWeight,
    required this.shadow,
  });

  final NavItem item;
  final String location;
  final ValueChanged<String> onNavigate;
  final double minWidth;
  final double padding;
  final double gap;
  final EdgeInsets childPadding;
  final FontWeight childWeight;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
        boxShadow: shadow,
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < item.children.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              _FlyoutRow(
                child: item.children[i],
                active: item.children[i].isActive(location),
                padding: childPadding,
                weight: childWeight,
                onTap: () => onNavigate(item.children[i].route),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlyoutRow extends StatefulWidget {
  const _FlyoutRow({
    required this.child,
    required this.active,
    required this.padding,
    required this.weight,
    required this.onTap,
  });
  final NavChild child;
  final bool active;
  final EdgeInsets padding;
  final FontWeight weight;
  final VoidCallback onTap;

  @override
  State<_FlyoutRow> createState() => _FlyoutRowState();
}

class _FlyoutRowState extends State<_FlyoutRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final active = widget.active;
    final color = active
        ? (dark ? Tw.indigo400 : Tw.indigo600)
        : _hover
            ? (dark ? Colors.white : Tw.slate900)
            : (dark ? Tw.slate300 : Tw.slate600);
    final bg = active
        ? (dark ? Tw.indigo950.withValues(alpha: 0.4) : Tw.indigo50)
        : _hover
            ? (dark ? Tw.slate800.withValues(alpha: 0.4) : Tw.slate50)
            : Colors.transparent;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
          child: Text(
            widget.child.label,
            softWrap: false,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: active ? FontWeight.w800 : widget.weight,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile bottom navigation — port of the `<nav>` in LeftSidebar.vue:
/// `h-16 px-1 bg-white/95 dark:bg-slate-900/95 border-t` with an upward
/// shadow; items are a 48×28 pill icon (`text-lg`) over a 9px bold label.
class MobileBottomNav extends ConsumerStatefulWidget {
  const MobileBottomNav({super.key, required this.location});
  final String location;

  @override
  ConsumerState<MobileBottomNav> createState() => _MobileBottomNavState();
}

class _MobileBottomNavState extends ConsumerState<MobileBottomNav> {
  String? _open;

  void _close() {
    if (_open != null) setState(() => _open = null);
  }

  @override
  void didUpdateWidget(covariant MobileBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) _open = null;
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final items = sidebarItemsFor(ref.watch(sessionProvider.select((s) => s.role)));
    return TapRegion(
      groupId: _navTapGroup,
      onTapOutside: (_) => _close(),
      child: Container(
        decoration: BoxDecoration(
          color: (dark ? Tw.slate900 : Colors.white).withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: dark ? Tw.slate800 : Tw.slate100)),
          boxShadow: [cssShadow(0, -4, 16, 0, Colors.black.withValues(alpha: dark ? 0.25 : 0.06))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: _BottomNavButton(
                        item: item,
                        location: widget.location,
                        open: _open == item.key,
                        onToggle: () => setState(() => _open = _open == item.key ? null : item.key),
                        onNavigate: (route) {
                          setState(() => _open = null);
                          context.go(route);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatefulWidget {
  const _BottomNavButton({
    required this.item,
    required this.location,
    required this.open,
    required this.onToggle,
    required this.onNavigate,
  });
  final NavItem item;
  final String location;
  final bool open;
  final VoidCallback onToggle;
  final ValueChanged<String> onNavigate;

  @override
  State<_BottomNavButton> createState() => _BottomNavButtonState();
}

class _BottomNavButtonState extends State<_BottomNavButton> with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _dropdown = OverlayPortalController();
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 150),
    value: widget.open ? 1 : 0,
  );
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _dropdown.show();
  }

  @override
  void didUpdateWidget(covariant _BottomNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) widget.open ? _anim.forward() : _anim.reverse();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final active = item.isActive(widget.location);
    final dark = context.isDark;
    final hasChildren = item.children.isNotEmpty;
    final color = active ? (dark ? Tw.indigo400 : Tw.indigo600) : (dark ? Tw.slate500 : Tw.slate400);
    final pill = active
        ? (dark ? Tw.indigo500.withValues(alpha: 0.2) : Tw.indigo600.withValues(alpha: 0.1))
        : _hover
            ? (dark ? Tw.slate800.withValues(alpha: 0.4) : Tw.slate50)
            : Colors.transparent;

    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hasChildren ? widget.onToggle : () => widget.onNavigate(item.route!),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 28,
                      // `w-12` even when the tab is narrower.
                      child: OverflowBox(
                        minWidth: 48,
                        maxWidth: 48,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 28,
                          decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(999)),
                          child: Icon(item.icon, size: 18, color: color),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.shortLabel ?? item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.225, // tracking-tight
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.open)
              Positioned(
                top: 10,
                right: 20,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Tw.indigo500,
                    shape: BoxShape.circle,
                    border: Border.all(color: dark ? Tw.slate900 : Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (!hasChildren) return button;

    // `absolute bottom-16 left-1/2 -translate-x-1/2 p-2.5 gap-1.5
    // min-w-[200px]`: just above the bar, centred on the tab.
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _dropdown,
        overlayChildBuilder: (_) => AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            if (_anim.isDismissed) return const SizedBox.shrink();
            final forward = _anim.status == AnimationStatus.forward || _anim.isCompleted;
            final t = (forward ? _overshoot : Curves.easeIn).transform(_anim.value);
            return Positioned(
              left: 0,
              top: 0,
              child: CompositedTransformFollower(
                link: _link,
                targetAnchor: Alignment.topCenter,
                followerAnchor: Alignment.bottomCenter,
                offset: Offset(0, -6 + 12 * (1 - t)),
                child: Transform.scale(
                  scale: 0.95 + 0.05 * t,
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: _anim.value,
                    child: TapRegion(
                      groupId: _navTapGroup,
                      child: _NavFlyout(
                        item: item,
                        location: widget.location,
                        onNavigate: widget.onNavigate,
                        minWidth: 200,
                        padding: 10,
                        gap: 6,
                        childPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        childWeight: FontWeight.w700,
                        shadow: [cssShadow(0, -4, 24, 0, Colors.black.withValues(alpha: dark ? 0.4 : 0.15))],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        child: button,
      ),
    );
  }
}
