import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'practice_timer_notifier.dart';
import 'practice_timer_state.dart';

class PracticeTimerDisplay extends ConsumerWidget {
  const PracticeTimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(activeTabProvider);
    // Don't show on Log tab.
    if (tab > 2) return const SizedBox.shrink();

    final seconds = ref.watch(
      practiceTimerProvider.select((s) => s.secondsForTab(tab)),
    );

    return Text(
      formatDuration(seconds),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    );
  }
}
