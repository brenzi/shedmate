import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/practice_timer/practice_timer_notifier.dart';
import '../../../common/practice_timer/practice_timer_state.dart';
import '../../../common/providers.dart';

class PracticeLogVersion extends ConsumerWidget {
  const PracticeLogVersion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(packageInfoProvider);
    return info.when(
      data: (i) => Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Center(
          child: Text(
            'v${i.version} (${i.buildNumber})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class PracticeLogScreen extends ConsumerWidget {
  const PracticeLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(practiceTimerProvider);
    final log = ref.read(practiceTimerProvider.notifier).getLog();

    // Combine historical log + today (most recent first).
    final entries = <PracticeTimerState>[
      if (today.totalSeconds > 0) today,
      ...log.reversed,
    ];

    if (entries.isEmpty) {
      return const Center(
        child: Text('No practice sessions yet.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final e = entries[index];
        return _LogRow(entry: e, isToday: index == 0 && today.totalSeconds > 0);
      },
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry, required this.isToday});

  final PracticeTimerState entry;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: [const FontFeature.tabularFigures()],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              isToday ? 'Today' : entry.date,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
          ),
          if (entry.practiceStart != null)
            SizedBox(
              width: 50,
              child: Text(entry.practiceStart!, style: mono),
            ),
          const SizedBox(width: 8),
          Text('N ', style: theme.textTheme.bodySmall),
          Text(formatDuration(entry.noteSeconds), style: mono),
          const SizedBox(width: 8),
          Text('M ', style: theme.textTheme.bodySmall),
          Text(formatDuration(entry.metronomeSeconds), style: mono),
          const SizedBox(width: 8),
          Text('P ', style: theme.textTheme.bodySmall),
          Text(formatDuration(entry.polyrhythmSeconds), style: mono),
        ],
      ),
    );
  }
}
