import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'message.dart';

part 'chat.g.dart';

@HiveType(typeId: 21)
class Chat extends Equatable {
  @HiveField(0)
  final String chatId;
  
  @HiveField(1)
  final ChatType type;
  
  @HiveField(2)
  final List<String> participantIds;
  
  @HiveField(3)
  final List<String> adminIds;
  
  @HiveField(4)
  final String? name;
  
  @HiveField(5)
  final String? description;
  
  @HiveField(6)
  final String? imageUrl;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime? updatedAt;
  
  @HiveField(9)
  final String? lastMessageId;
  
  @HiveField(10)
  final String? lastMessageContent;
  
  @HiveField(11)
  final DateTime? lastMessageTime;
  
  @HiveField(12)
  final String? lastMessageSenderId;
  
  @HiveField(13)
  final Map<String, int> unreadCounts;
  
  @HiveField(14)
  final Map<String, dynamic> settings;
  
  @HiveField(15)
  final bool isActive;
  
  @HiveField(16)
  final String? createdBy;

  // Convenience getter for lastMessage
  String? get lastMessage => lastMessageContent;

  const Chat({
    required this.chatId,
    required this.type,
    required this.participantIds,
    required this.adminIds,
    this.name,
    this.description,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCounts = const {},
    this.settings = const {},
    this.isActive = true,
    this.createdBy,
  });

  factory Chat.direct({
    required String participantUserId,
    required String currentUserId,
  }) {
    final sortedIds = [currentUserId, participantUserId]..sort();
    return Chat(
      chatId: 'direct_${sortedIds[0]}_${sortedIds[1]}',
      type: ChatType.direct,
      participantIds: [currentUserId, participantUserId],
      adminIds: const [],
      name: null,
      description: null,
      imageUrl: null,
      createdAt: DateTime.now(),
      lastMessageContent: null,
      lastMessageTime: null,
      unreadCounts: {currentUserId: 0, participantUserId: 0},
      settings: const {},
      isActive: true,
    );
  }

  factory Chat.group({
    required String name,
    required String creatorId,
    required List<String> participantIds,
    String? description,
    String? imageUrl,
  }) {
    final allParticipants = [...participantIds];
    if (!allParticipants.contains(creatorId)) {
      allParticipants.add(creatorId);
    }
    
    return Chat(
      chatId: 'group_${DateTime.now().millisecondsSinceEpoch}_$creatorId',
      type: ChatType.group,
      participantIds: allParticipants,
      adminIds: [creatorId],
      name: name,
      description: description,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      lastMessageContent: null,
      lastMessageTime: null,
      unreadCounts: {for (String id in allParticipants) id: 0},
      settings: const {},
      isActive: true,
      createdBy: creatorId,
    );
  }

  factory Chat.team({
    required String teamName,
    required String creatorId,
    required List<String> memberIds,
    String? description,
    String? imageUrl,
  }) {
    final allMembers = [...memberIds];
    if (!allMembers.contains(creatorId)) {
      allMembers.add(creatorId);
    }
    
    return Chat(
      chatId: 'team_${DateTime.now().millisecondsSinceEpoch}_$creatorId',
      type: ChatType.team,
      participantIds: allMembers,
      adminIds: [creatorId],
      name: teamName,
      description: description,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      lastMessageContent: null,
      lastMessageTime: null,
      unreadCounts: {for (String id in allMembers) id: 0},
      settings: const {},
      isActive: true,
      createdBy: creatorId,
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'] as String,
      type: ChatType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ChatType.direct,
      ),
      participantIds: List<String>.from(json['participantIds'] ?? []),
      adminIds: List<String>.from(json['adminIds'] ?? []),
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageContent: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null 
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'type': type.toString().split('.').last,
      'participantIds': participantIds,
      'adminIds': adminIds,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessageContent,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCounts': unreadCounts,
      'settings': settings,
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }

  Chat copyWith({
    String? name,
    String? description,
    String? imageUrl,
    List<String>? participantIds,
    List<String>? adminIds,
    DateTime? updatedAt,
    String? lastMessageId,
    String? lastMessageContent,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCounts,
    Map<String, dynamic>? settings,
    bool? isActive,
  }) {
    return Chat(
      chatId: chatId,
      type: type,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      participantIds: participantIds ?? this.participantIds,
      adminIds: adminIds ?? this.adminIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
    );
  }

  Chat updateLastMessage(Message message) {
    return copyWith(
      lastMessageId: message.messageId,
      lastMessageContent: message.isSystemMessage 
          ? message.content 
          : message.type == MessageType.image 
              ? '📷 Photo' 
              : message.content,
      lastMessageTime: message.createdAt,
      lastMessageSenderId: message.senderId,
      updatedAt: DateTime.now(),
    );
  }

  Chat incrementUnreadCount(String userId) {
    if (userId == lastMessageSenderId) return this; // Don't increment for sender
    
    final updatedUnreadCounts = Map<String, int>.from(unreadCounts);
    updatedUnreadCounts[userId] = (updatedUnreadCounts[userId] ?? 0) + 1;
    
    return copyWith(unreadCounts: updatedUnreadCounts);
  }

  Chat markAsRead(String userId) {
    final updatedUnreadCounts = Map<String, int>.from(unreadCounts);
    updatedUnreadCounts.remove(userId);
    
    return copyWith(unreadCounts: updatedUnreadCounts);
  }

  Chat addParticipant(String userId) {
    if (participantIds.contains(userId)) return this;
    
    final updatedParticipants = List<String>.from(participantIds)..add(userId);
    return copyWith(
      participantIds: updatedParticipants,
      updatedAt: DateTime.now(),
    );
  }

  Chat removeParticipant(String userId) {
    final updatedParticipants = List<String>.from(participantIds)..remove(userId);
    final updatedAdmins = List<String>.from(adminIds)..remove(userId);
    
    return copyWith(
      participantIds: updatedParticipants,
      adminIds: updatedAdmins,
      updatedAt: DateTime.now(),
    );
  }

  Chat addAdmin(String userId) {
    if (!participantIds.contains(userId) || adminIds.contains(userId)) return this;
    
    final updatedAdmins = List<String>.from(adminIds)..add(userId);
    return copyWith(
      adminIds: updatedAdmins,
      updatedAt: DateTime.now(),
    );
  }

  Chat removeAdmin(String userId) {
    final updatedAdmins = List<String>.from(adminIds)..remove(userId);
    return copyWith(
      adminIds: updatedAdmins,
      updatedAt: DateTime.now(),
    );
  }

  // Helper getters
  bool get isDirectMessage => type == ChatType.direct;
  bool get isGroupChat => type == ChatType.group;
  bool get isTeamChat => type == ChatType.team;
  bool get hasUnreadMessages => unreadCounts.isNotEmpty;
  
  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;
  
  bool isAdmin(String userId) => adminIds.contains(userId);
  bool isParticipant(String userId) => participantIds.contains(userId);
  
  String get displayName {
    if (isDirectMessage && participantIds.length == 2) {
      // For direct messages, we'll need to get the other user's name
      // This will be handled in the UI layer
      return name!;
    }
    return name!;
  }
  
  String get lastMessagePreview {
    if (lastMessageContent == null) return 'No messages yet';
    
    final content = lastMessageContent!;
    if (content.length > 50) {
      return '${content.substring(0, 50)}...';
    }
    return content;
  }
  
  String get timeAgo {
    if (lastMessageTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);
    
    if (difference.inDays > 7) {
      return '${lastMessageTime!.day}/${lastMessageTime!.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  List<Object?> get props => [
        chatId,
        type,
        name,
        description,
        imageUrl,
        participantIds,
        adminIds,
        createdAt,
        updatedAt,
        lastMessageId,
        lastMessageContent,
        lastMessageTime,
        lastMessageSenderId,
        unreadCounts,
        settings,
        isActive,
        createdBy,
      ];
}

@HiveType(typeId: 22)
enum ChatType {
  @HiveField(0)
  direct,
  
  @HiveField(1)
  group,
  
  @HiveField(2)
  team,
  
  @HiveField(3)
  event,
}

// Chat member information
@HiveType(typeId: 23)
class ChatMember extends Equatable {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final String displayName;
  
  @HiveField(2)
  final String? imageUrl;
  
  @HiveField(3)
  final ChatMemberRole role;
  
  @HiveField(4)
  final DateTime joinedAt;
  
  @HiveField(5)
  final DateTime? lastSeenAt;
  
  @HiveField(6)
  final bool isOnline;

  const ChatMember({
    required this.userId,
    required this.displayName,
    this.imageUrl,
    required this.role,
    required this.joinedAt,
    this.lastSeenAt,
    this.isOnline = false,
  });

  ChatMember copyWith({
    String? displayName,
    String? imageUrl,
    ChatMemberRole? role,
    DateTime? lastSeenAt,
    bool? isOnline,
  }) {
    return ChatMember(
      userId: userId,
      displayName: displayName ?? this.displayName,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      joinedAt: joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        imageUrl,
        role,
        joinedAt,
        lastSeenAt,
        isOnline,
      ];
}

@HiveType(typeId: 24)
enum ChatMemberRole {
  @HiveField(0)
  member,
  
  @HiveField(1)
  admin,
  
  @HiveField(2)
  owner,
} 