class GroupMember {
  final String userId;
  final String displayName;
  final String maskedPhone; // e.g. ***-***-5678
  final String role; // 'creator' or 'member'
  final DateTime joinedAt;

  GroupMember({
    required this.userId,
    required this.displayName,
    required this.maskedPhone,
    required this.role,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      maskedPhone: json['maskedPhone'] as String? ?? '***-***-0000',
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'maskedPhone': maskedPhone,
    'role': role,
    'joinedAt': joinedAt.toIso8601String(),
  };
}

class VoiceGroup {
  final String id;
  final String name;
  final String topic;
  final String description;
  final String creatorId;
  final String creatorName;
  final String iconCode;
  final String inviteCode;
  final List<GroupMember> members;
  final DateTime createdAt;

  VoiceGroup({
    required this.id,
    required this.name,
    required this.topic,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.iconCode,
    required this.inviteCode,
    required this.members,
    required this.createdAt,
  });

  factory VoiceGroup.fromJson(Map<String, dynamic> json) {
    var memberList = (json['members'] as List<dynamic>? ?? [])
        .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
        .toList();
    return VoiceGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      topic: json['topic'] as String? ?? 'General Chat',
      description: json['description'] as String? ?? '',
      creatorId: json['creatorId'] as String? ?? 'user_1',
      creatorName: json['creatorName'] as String? ?? 'Group Creator',
      iconCode: json['iconCode'] as String? ?? 'group',
      inviteCode: json['inviteCode'] as String? ?? 'ELDER-100',
      members: memberList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'topic': topic,
    'description': description,
    'creatorId': creatorId,
    'creatorName': creatorName,
    'iconCode': iconCode,
    'inviteCode': inviteCode,
    'members': members.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}
