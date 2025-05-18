class CallMinutes {
  int audioPurchased;
  int audioUsed;
  int videoPurchased;
  int videoUsed;

  CallMinutes({
    this.audioPurchased = 0,
    this.audioUsed = 0,
    this.videoPurchased = 0,
    this.videoUsed = 0,
  });

  int get audioAvailable => audioPurchased - audioUsed;
  int get videoAvailable => videoPurchased - videoUsed;

  Map<String, dynamic> toMap() {
    return {
      'audioPurchased': audioPurchased,
      'audioUsed': audioUsed,
      'videoPurchased': videoPurchased,
      'videoUsed': videoUsed,
    };
  }

  factory CallMinutes.fromMap(Map<String, dynamic>? map) {
    if (map == null) return CallMinutes();

    return CallMinutes(
      audioPurchased: map['audioPurchased'] ?? 0,
      audioUsed: map['audioUsed'] ?? 0,
      videoPurchased: map['videoPurchased'] ?? 0,
      videoUsed: map['videoUsed'] ?? 0,
    );
  }

  CallMinutes copyWith({
    int? audioPurchased,
    int? audioUsed,
    int? videoPurchased,
    int? videoUsed,
  }) {
    return CallMinutes(
      audioPurchased: audioPurchased ?? this.audioPurchased,
      audioUsed: audioUsed ?? this.audioUsed,
      videoPurchased: videoPurchased ?? this.videoPurchased,
      videoUsed: videoUsed ?? this.videoUsed,
    );
  }
}
