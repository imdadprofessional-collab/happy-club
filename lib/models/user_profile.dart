class UserProfile {
  UserProfile({
    required this.name,
    required this.avatarEmoji,
    required this.joinDate,
  });

  String name;
  String avatarEmoji;
  final DateTime joinDate;

  Map<String, dynamic> toJson() => {
    'name': name,
    'avatarEmoji': avatarEmoji,
    'joinDate': joinDate.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String,
    avatarEmoji: json['avatarEmoji'] as String,
    joinDate: DateTime.parse(json['joinDate'] as String),
  );

  factory UserProfile.fresh() =>
      UserProfile(name: 'Friend', avatarEmoji: '🙂', joinDate: DateTime.now());
}
