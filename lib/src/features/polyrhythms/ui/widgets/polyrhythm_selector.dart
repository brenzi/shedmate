import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/polyrhythm_providers.dart';

class PolyrhythmSelector extends ConsumerWidget {
  const PolyrhythmSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(polyrhythmProvider.select((s) => s.a));
    final b = ref.watch(polyrhythmProvider.select((s) => s.b));
    final showSub = ref.watch(
      polyrhythmProvider.select((s) => s.showSubdivision),
    );
    final notifier = ref.read(polyrhythmProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: a > 1 ? () => notifier.setA(a - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$a',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: a < 11 ? () => notifier.setA(a + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: b > 1 ? () => notifier.setB(b - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$b',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: b < 11 ? () => notifier.setB(b + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          showSub
              ? FilledButton.tonal(
                  onPressed: notifier.toggleSubdivision,
                  child: const Text('Subdivision'),
                )
              : OutlinedButton(
                  onPressed: notifier.toggleSubdivision,
                  child: const Text('Subdivision'),
                ),
        ],
      ),
    );
  }
}
