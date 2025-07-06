import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { sending, sent, delivered, failed }

enum MessageType { text, typing, system }

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.status,
    this.type = MessageType.text,
    this.metadata,
  });

  factory ChatMessage.user({
    required String id,
    required String content,
    required MessageStatus status,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      status: status,
      type: MessageType.text,
      metadata: metadata,
    );
  }

  factory ChatMessage.ai({
    required String id,
    required String content,
    required MessageStatus status,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      status: status,
      type: MessageType.text,
      metadata: metadata,
    );
  }

  factory ChatMessage.typing({required String id}) {
    return ChatMessage(
      id: id,
      content: 'AI is typing...',
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      type: MessageType.typing,
    );
  }

  factory ChatMessage.system({required String id, required String content}) {
    return ChatMessage(
      id: id,
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      type: MessageType.system,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isTyping => type == MessageType.typing;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.toString(),
      'type': type.toString(),
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status.toString(),
      'type': type.toString(),
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: data['id'] as String,
      content: data['content'] as String,
      isUser: data['isUser'] as bool,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => MessageType.text,
      ),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isUser,
    timestamp,
    status,
    type,
    metadata,
  ];
}
