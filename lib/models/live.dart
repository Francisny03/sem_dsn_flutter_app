/// Statut du direct renvoyé par l'API.
enum LiveStatus { live, scheduled, ended }

/// Config du direct (une seule par app).
class Live {
  const Live({
    required this.id,
    required this.url,
    required this.liveId,
    required this.platform,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.scheduledAt,
  });

  final int id;
  final String url;
  final String liveId;
  final String platform;
  final LiveStatus status;
  final String createdAt;
  final String updatedAt;

  /// Date/heure prévue du direct (pour plus tard).
  final String? scheduledAt;

  bool get isLive => status == LiveStatus.live;
  bool get isScheduled => status == LiveStatus.scheduled;
  bool get isEnded => status == LiveStatus.ended;

  /// Contenu affichable (live, programmé ou recap).
  bool get hasContent => url.isNotEmpty;

  static LiveStatus _statusFromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'live':
        return LiveStatus.live;
      case 'scheduled':
        return LiveStatus.scheduled;
      case 'ended':
        return LiveStatus.ended;
      default:
        return LiveStatus.ended;
    }
  }

  factory Live.fromJson(Map<String, dynamic> json) {
    return Live(
      id: json['id'] as int,
      url: json['url'] as String? ?? '',
      liveId: json['live_id'] as String? ?? '',
      platform: json['platform'] as String? ?? 'youtube',
      status: _statusFromString(json['status'] as String?),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      scheduledAt: json['scheduled_at'] as String?,
    );
  }
}
