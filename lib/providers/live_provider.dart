import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'package:sem_dsn/core/constants/live_config.dart';
import 'package:sem_dsn/models/live.dart';
import 'package:sem_dsn/services/lives_api.dart';

/// Provider du direct : une config par app, chargée au démarrage et au refresh.
class LiveProvider extends ChangeNotifier {
  Live? _currentLive;
  bool _loading = false;

  Live? get currentLive => _currentLive;
  bool get loading => _loading;

  /// En direct → icône qui clignote.
  bool get isLiveInProgress => _currentLive?.isLive ?? false;

  /// Replay → carte hero avec tag Replay, icône noire.
  bool get isReplay => _currentLive?.isReplay ?? false;

  /// Terminé → icône grise, non cliquable, pas de slide live/replay dans le hero.
  bool get isEnded => _currentLive?.isEnded ?? false;

  /// Contenu dispo (live, programmé, replay ou recap).
  bool get hasLiveContent => _currentLive?.hasContent ?? false;

  /// URL YouTube du direct (live ou programmé).
  String get youtubeLiveUrl => _currentLive?.url ?? '';

  /// Recap = même URL pour l’instant (quand status == ended).
  String get recapVideoUrl => _currentLive?.url ?? '';

  /// True si le direct actuel est un flux HLS (pas YouTube).
  bool get isHlsLive =>
      _currentLive != null &&
      (_currentLive!.platform.toUpperCase() == 'HLS' ||
          _currentLive!.url.trim().toLowerCase().endsWith('.m3u8'));

  /// Charge la config si pas déjà chargée (au démarrage).
  Future<void> loadIfNeeded() async {
    if (_loading || _currentLive != null) return;
    await load();
  }

  /// Force le rechargement (ex. pull-to-refresh).
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      var live = await fetchLive();
      if (live != null && LiveConfig.forceStatusForTest != null) {
        live = live.copyWithStatus(LiveConfig.forceStatusForTest!);
      }
      _currentLive = live;
    } catch (_) {
      _currentLive = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
