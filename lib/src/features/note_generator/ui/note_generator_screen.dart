import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/mixer/mixer_sheet.dart';
import 'widgets/note_display.dart';
import 'widgets/note_rules.dart';
import 'widgets/range_selector.dart';
import 'widgets/tempo_controls.dart';
import 'widgets/transport_controls.dart';

class NoteGeneratorScreen extends ConsumerWidget {
  const NoteGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => showMixerSheet(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NoteDisplay(),
                  Divider(height: 1),
                  RangeSelector(),
                  Divider(height: 1),
                  NoteRules(),
                  Divider(height: 1),
                  TempoControls(),
                  Divider(height: 1),
                  TransportControls(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
