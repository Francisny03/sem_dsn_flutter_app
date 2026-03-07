/// Static configuration for the live stream feature.
/// When backend is ready, replace with API (e.g. liveInProgress, liveUrl, recapUrl).
class LiveConfig {
  LiveConfig._();

  /// When true: live icon blinks red in header; tap opens HLS live.
  /// When false: tap opens YouTube recap (recapVideoUrl).
  static const bool isLiveInProgress = false;

  /// HLS stream URL for the live (used when [isLiveInProgress] is true).
  static const String liveStreamUrl =
      'https://streaming.streampay.cloud:8060/live/1Music_/playlist.m3u8';

  /// YouTube URL for the recap (used when [isLiveInProgress] is false).
  /// Empty or placeholder until recap is available.
  static const String recapVideoUrl =
      'https://www.youtube.com/watch?v=6RLheM5AZmc';

  /// When true: live stream is vertical → player aspect 9/16. Otherwise 16/9.
  static const bool liveStreamIsVertical = false;

  /// When true: recap video is vertical → player aspect 9/16. Otherwise 16/9.
  static const bool recapVideoIsVertical = false;
}
