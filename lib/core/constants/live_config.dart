import 'package:sem_dsn/models/live.dart';

/// Source du live pour les tests : HLS (flux .m3u8) ou YouTube (URL live/replay).
enum LiveSource {
  /// Utiliser [LiveConfig.liveStreamUrl] (HLS) quand [LiveConfig.isLiveInProgress] est true.
  hls,

  /// Utiliser [LiveConfig.youtubeLiveUrl] (YouTube live) quand [LiveConfig.isLiveInProgress] est true.
  youtube,
}

/// Static configuration for the live stream feature.
/// When backend is ready, replace with API (e.g. liveInProgress, liveUrl, recapUrl).
class LiveConfig {
  LiveConfig._();

  /// Quelle source utiliser pour le direct : [LiveSource.hls] ou [LiveSource.youtube].
  /// Change cette valeur pour tester HLS ou YouTube live.
  static const LiveSource liveSource = LiveSource.youtube;

  /// When true: live icon blinks red in header; tap opens live (HLS or YouTube according to [liveSource]).
  /// When false: tap opens YouTube recap ([recapVideoUrl]).
  static const bool isLiveInProgress = true;

  /// HLS stream URL for the live (used when [isLiveInProgress] is true and [liveSource] is [LiveSource.hls]).
  static const String liveStreamUrl =
      'https://streaming.streampay.cloud:8060/live/1Music_/playlist.m3u8';

  /// YouTube live URL (used when [isLiveInProgress] is true and [liveSource] is [LiveSource.youtube]).
  /// Ex: https://www.youtube.com/live/6k6_IJFELpg
  static const String youtubeLiveUrl =
      'https://www.youtube.com/watch?v=XtwNWKkOc-w';

  /// YouTube URL for the recap (used when [isLiveInProgress] is false).
  /// Empty or placeholder until recap is available.
  static const String recapVideoUrl =
      'https://www.youtube.com/watch?v=6RLheM5AZmc';

  /// When true: live stream is vertical → player aspect 9/16. Otherwise 16/9.
  static const bool liveStreamIsVertical = false;

  /// When true: recap video is vertical → player aspect 9/16. Otherwise 16/9.
  static const bool recapVideoIsVertical = false;

  /// Pour les tests : force le statut du live après fetch (ex. [LiveStatus.replay]).
  /// Null = utiliser le statut renvoyé par l'API.
  static const LiveStatus? forceStatusForTest =
      LiveStatus.replay; // Mettre LiveStatus.replay pour tester

  /// True si on a au moins une source à afficher (direct ou replay).
  static bool get hasLiveContent {
    if (isLiveInProgress) {
      if (liveSource == LiveSource.hls) return liveStreamUrl.isNotEmpty;
      return youtubeLiveUrl.isNotEmpty;
    }
    return recapVideoUrl.isNotEmpty;
  }
}
