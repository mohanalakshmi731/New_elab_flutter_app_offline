import 'package:flutter/material.dart';

/// A compact learning toolbar above a viewport that gets all remaining space.
class OfflineWorkspace extends StatelessWidget {
  const OfflineWorkspace({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tabs,
    required this.selectedTab,
    required this.onTab,
    required this.child,
    required this.onBack,
    required this.onBrowse,
    required this.onFullscreen,
    required this.onRestart,
    required this.onFinish,
    this.onPrevious,
    this.onNext,
    this.completed = false,
    this.fullscreen = false,
    this.error,
    this.learningStatus,
    this.onSwitchOnline,
  });
  final String title, subtitle;
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int> onTab;
  final Widget child;
  final VoidCallback onBack, onBrowse, onFullscreen, onRestart, onFinish;
  final VoidCallback? onPrevious, onNext;
  final bool completed, fullscreen;
  final String? error;
  final String? learningStatus;
  final VoidCallback? onSwitchOnline;

  static const _icons = [
    Icons.science_outlined,
    Icons.lightbulb_outline,
    Icons.play_circle_outline,
    Icons.menu_book_outlined,
    Icons.insights_outlined,
    Icons.touch_app_outlined,
    Icons.quiz_outlined,
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final colors = Theme.of(context).colorScheme;
      final compact = bounds.maxWidth < 700;
      return ColoredBox(
        color: colors.surfaceContainerLowest,
        child: Column(
          children: [
            if (!fullscreen) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 4 : 12,
                  8,
                  compact ? 4 : 16,
                  4,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      tooltip: 'Back to library',
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tooltip(
                            message: title,
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: compact ? 18 : 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.4,
                              ),
                            ),
                          ),
                          if (learningStatus != null)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                  learningStatus!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                if (onSwitchOnline != null)
                                  TextButton(
                                    onPressed: onSwitchOnline,
                                    child: const Text('Switch to online'),
                                  ),
                              ],
                            ),
                          if (subtitle.isNotEmpty)
                            Tooltip(
                              message: subtitle,
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      Icon(
                        Icons.cloud_done_outlined,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Saved on this device',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: onPrevious,
                        tooltip: 'Previous activity',
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed: onNext,
                        tooltip: 'Next activity',
                        icon: const Icon(Icons.chevron_right),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        onPressed: onFullscreen,
                        icon: const Icon(Icons.fullscreen_rounded),
                        label: const Text('Focus view'),
                      ),
                    ] else
                      IconButton(
                        onPressed: onFullscreen,
                        tooltip: 'Focus view',
                        icon: const Icon(Icons.fullscreen_rounded),
                      ),
                    PopupMenuButton<String>(
                      tooltip: 'Learning options',
                      onSelected: (value) {
                        switch (value) {
                          case 'browse':
                            onBrowse();
                          case 'restart':
                            onRestart();
                          case 'finish':
                            onFinish();
                          case 'previous':
                            onPrevious?.call();
                          case 'next':
                            onNext?.call();
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'browse',
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.view_list_outlined),
                            title: Text('Browse activities'),
                          ),
                        ),
                        if (compact)
                          PopupMenuItem(
                            value: 'previous',
                            enabled: onPrevious != null,
                            child: const Text('Previous activity'),
                          ),
                        if (compact)
                          PopupMenuItem(
                            value: 'next',
                            enabled: onNext != null,
                            child: const Text('Next activity'),
                          ),
                        const PopupMenuItem(
                          value: 'restart',
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.restart_alt),
                            title: Text('Restart activity'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'finish',
                          enabled: !completed,
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              completed
                                  ? Icons.check_circle_outline
                                  : Icons.flag_outlined,
                            ),
                            title: Text(
                              completed ? 'Completed' : 'Finish activity',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 20),
                  child: Row(
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: TextButton.icon(
                            onPressed: () => onTab(i),
                            icon: Icon(
                              _icons[i % _icons.length],
                              size: 18,
                              color: selectedTab == i
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                            ),
                            label: Text(
                              tabs[i],
                              style: TextStyle(
                                color: selectedTab == i
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                                fontWeight: selectedTab == i
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: selectedTab == i
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                              backgroundColor: selectedTab == i
                                  ? colors.primary
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Text(error!, style: TextStyle(color: colors.error)),
                ),
            ],
            Expanded(
              child: Padding(
                padding: fullscreen
                    ? EdgeInsets.zero
                    : EdgeInsets.fromLTRB(
                        compact ? 6 : 12,
                        6,
                        compact ? 6 : 12,
                        compact ? 6 : 12,
                      ),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(fullscreen ? 0 : 18),
                    border: fullscreen
                        ? null
                        : Border.all(
                            color: colors.outlineVariant.withValues(alpha: .6),
                          ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(child: child),
                      if (fullscreen)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: FilledButton.tonalIcon(
                            onPressed: onFullscreen,
                            icon: const Icon(Icons.fullscreen_exit),
                            label: const Text('Exit focus view'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Documents scroll inside their viewer rather than a small fixed-height frame.
class OfflineSupportWorkspace extends StatelessWidget {
  const OfflineSupportWorkspace({
    super.key,
    required this.panels,
    required this.labels,
  });
  final List<Widget> panels;
  final List<String> labels;
  @override
  Widget build(BuildContext context) {
    if (panels.isEmpty)
      return const Center(
        child: Text('No supporting material was supplied for this activity.'),
      );
    if (panels.length == 1) return panels.single;
    return DefaultTabController(
      length: panels.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final label in labels) Tab(text: label)],
          ),
          Expanded(child: TabBarView(children: panels)),
        ],
      ),
    );
  }
}
