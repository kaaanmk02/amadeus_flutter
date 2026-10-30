class PersonalityAnimation {
  final double scale;
  final double rotation;
  final Offset offset;
  final Duration duration;
  final Curve curve;

  const PersonalityAnimation({
    this.scale = 1.0,
    this.rotation = 0.0,
    this.offset = Offset.zero,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  PersonalityAnimation copyWith({
    double? scale,
    double? rotation,
    Offset? offset,
    Duration? duration,
    Curve? curve,
  }) {
    return PersonalityAnimation(
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      offset: offset ?? this.offset,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }
}
