class UserPreferences {
  final bool darkMode;
  final List<String> preferredTags;
  final List<String> preferredPriceRanges;

  UserPreferences({
    this.darkMode = true,
    this.preferredTags = const [],
    this.preferredPriceRanges = const [],
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      darkMode: map['darkMode'] ?? true,
      preferredTags:
          List<String>.from(map['preferredTags'] ?? []),
      preferredPriceRanges:
          List<String>.from(map['preferredPriceRanges'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'preferredTags': preferredTags,
      'preferredPriceRanges': preferredPriceRanges,
    };
  }
}