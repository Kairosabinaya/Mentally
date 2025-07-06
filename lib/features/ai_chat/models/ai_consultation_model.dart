import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_message_model.dart';

enum ConsultationCategory {
  general,
  anxiety,
  depression,
  stress,
  relationships,
  sleep,
  selfEsteem,
  grief,
  trauma,
  addiction,
}

enum ConsultationStatus { active, completed, paused, cancelled }

class AiConsultation extends Equatable {
  final String id;
  final String userId;
  final String title;
  final ConsultationCategory category;
  final ConsultationStatus status;
  final List<ChatMessage> messages;
  final DateTime startTime;
  final DateTime? endTime;
  final double? moodBefore;
  final double? moodAfter;
  final String? notes;
  final bool isBookmarked;
  final Map<String, dynamic>? metadata;

  const AiConsultation({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.status,
    required this.messages,
    required this.startTime,
    this.endTime,
    this.moodBefore,
    this.moodAfter,
    this.notes,
    this.isBookmarked = false,
    this.metadata,
  });

  factory AiConsultation.create({
    String? id,
    required String userId,
    required ConsultationCategory category,
    String? title,
    String? initialMessage,
    double? moodBefore,
  }) {
    final now = DateTime.now();
    final consultationId = id ?? 'consultation_${now.millisecondsSinceEpoch}';

    final messages = <ChatMessage>[];
    if (initialMessage != null && initialMessage.isNotEmpty) {
      messages.add(
        ChatMessage.user(
          id: 'msg_${now.millisecondsSinceEpoch}',
          content: initialMessage,
          status: MessageStatus.sent,
        ),
      );
    }

    return AiConsultation(
      id: consultationId,
      userId: userId,
      title: title ?? _getDefaultTitle(category),
      category: category,
      status: ConsultationStatus.active,
      messages: messages,
      startTime: now,
      moodBefore: moodBefore?.toDouble(),
    );
  }

  static String _getDefaultTitle(ConsultationCategory category) {
    switch (category) {
      case ConsultationCategory.general:
        return 'General Consultation';
      case ConsultationCategory.anxiety:
        return 'Anxiety Support';
      case ConsultationCategory.depression:
        return 'Depression Support';
      case ConsultationCategory.stress:
        return 'Stress Management';
      case ConsultationCategory.relationships:
        return 'Relationship Guidance';
      case ConsultationCategory.sleep:
        return 'Sleep Issues';
      case ConsultationCategory.selfEsteem:
        return 'Self-Esteem Support';
      case ConsultationCategory.grief:
        return 'Grief Support';
      case ConsultationCategory.trauma:
        return 'Trauma Support';
      case ConsultationCategory.addiction:
        return 'Addiction Support';
    }
  }

  AiConsultation copyWith({
    String? id,
    String? userId,
    String? title,
    ConsultationCategory? category,
    ConsultationStatus? status,
    List<ChatMessage>? messages,
    DateTime? startTime,
    DateTime? endTime,
    double? moodBefore,
    double? moodAfter,
    String? notes,
    bool? isBookmarked,
    Map<String, dynamic>? metadata,
    Duration? duration,
    int? messageCount,
    DateTime? updatedAt,
  }) {
    return AiConsultation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      notes: notes ?? this.notes,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      metadata: metadata ?? this.metadata,
    );
  }

  AiConsultation addMessage(ChatMessage message) {
    return copyWith(messages: [...messages, message]);
  }

  AiConsultation updateMessage(ChatMessage updatedMessage) {
    final updatedMessages =
        messages.map((msg) {
          return msg.id == updatedMessage.id ? updatedMessage : msg;
        }).toList();

    return copyWith(messages: updatedMessages);
  }

  AiConsultation removeMessage(String messageId) {
    final updatedMessages =
        messages.where((msg) => msg.id != messageId).toList();
    return copyWith(messages: updatedMessages);
  }

  AiConsultation updateLastMessage(ChatMessage message) {
    if (messages.isEmpty) {
      return addMessage(message);
    }
    final updatedMessages = [...messages];
    updatedMessages[updatedMessages.length - 1] = message;
    return copyWith(messages: updatedMessages);
  }

  // Getters
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get formattedDuration {
    final d = duration;
    if (d.inMinutes < 1) {
      return '${d.inSeconds}s';
    } else if (d.inHours < 1) {
      return '${d.inMinutes}m ${d.inSeconds % 60}s';
    } else {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
  }

  int get messageCount => messages.length;

  bool get isActive => status == ConsultationStatus.active;

  bool get isCompleted => status == ConsultationStatus.completed;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'category': category.toString(),
      'status': status.toString(),
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'notes': notes,
      'isBookmarked': isBookmarked,
      'metadata': metadata,
    };
  }

  factory AiConsultation.fromJson(Map<String, dynamic> json) {
    return AiConsultation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      category: ConsultationCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ConsultationCategory.general,
      ),
      status: ConsultationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ConsultationStatus.active,
      ),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
              .toList() ??
          [],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime:
          json['endTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int)
              : null,
      moodBefore: (json['moodBefore'] as num?)?.toDouble(),
      moodAfter: (json['moodAfter'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'category': category.toString(),
      'status': status.toString(),
      'messages': messages.map((msg) => msg.toFirestore()).toList(),
      'startTime': FieldValue.serverTimestamp(),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'notes': notes,
      'isBookmarked': isBookmarked,
      'metadata': metadata,
    };
  }

  factory AiConsultation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AiConsultation(
      id: data['id'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      category: ConsultationCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => ConsultationCategory.general,
      ),
      status: ConsultationStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => ConsultationStatus.active,
      ),
      messages:
          (data['messages'] as List<dynamic>?)
              ?.map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
              .toList() ??
          [],
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      moodBefore: (data['moodBefore'] as num?)?.toDouble(),
      moodAfter: (data['moodAfter'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      isBookmarked: data['isBookmarked'] as bool? ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    category,
    status,
    messages,
    startTime,
    endTime,
    moodBefore,
    moodAfter,
    notes,
    isBookmarked,
    metadata,
  ];
}
