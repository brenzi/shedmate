import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
