import 'package:flutter/foundation.dart' show ChangeNotifier;

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

  /// Contenu dispo (live, programmé ou recap).
  bool get hasLiveContent => _currentLive?.hasContent ?? false;

  /// URL YouTube du direct (live ou programmé).
  String get youtubeLiveUrl => _currentLive?.url ?? '';

  /// Recap = même URL pour l’instant (quand status == ended).
  String get recapVideoUrl => _currentLive?.url ?? '';

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
      _currentLive = await fetchLive();
    } catch (_) {
      _currentLive = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
