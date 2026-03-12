/// Statut du direct renvoyé par l'API.
enum LiveStatus { live, scheduled, ended, replay }

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
    this.image,
    this.title,
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

  /// Image pour la carte hero (backend: live_image).
  final String? image;

  /// Titre pour la carte hero (backend: live_title).
  final String? title;

  bool get isLive => status == LiveStatus.live;
  bool get isScheduled => status == LiveStatus.scheduled;
  bool get isEnded => status == LiveStatus.ended;
  bool get isReplay => status == LiveStatus.replay;

  /// Contenu affichable (live, programmé ou recap).
  bool get hasContent => url.isNotEmpty;

  /// Nouvelle instance avec un statut différent (ex. pour [LiveConfig.forceStatusForTest]).
  Live copyWithStatus(LiveStatus newStatus) {
    return Live(
      id: id,
      url: url,
      liveId: liveId,
      platform: platform,
      status: newStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      scheduledAt: scheduledAt,
      image: image,
      title: title,
    );
  }

  static LiveStatus _statusFromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'live':
        return LiveStatus.live;
      case 'scheduled':
        return LiveStatus.scheduled;
      case 'ended':
        return LiveStatus.ended;
      case 'replay':
        return LiveStatus.replay;
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
      image: (json['live_image'] ?? json['image']) as String?,
      title: (json['live_title'] ?? json['title']) as String?,
    );
  }
}
