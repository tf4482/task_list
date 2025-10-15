import 'package:intl/intl.dart';

enum RenewalType {
  none,
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case RenewalType.none:
        return 'No Renewal';
      case RenewalType.daily:
        return 'Daily';
      case RenewalType.weekly:
        return 'Weekly';
      case RenewalType.monthly:
        return 'Monthly';
    }
  }
}

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  RenewalType renewalType;
  DateTime? lastRenewalDate;
  DateTime? nextRenewalDate;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.renewalType = RenewalType.none,
    this.lastRenewalDate,
    this.nextRenewalDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    if (renewalType != RenewalType.none && nextRenewalDate == null) {
      _calculateNextRenewalDate();
    }
  }

  void _calculateNextRenewalDate() {
    final now = DateTime.now();
    switch (renewalType) {
      case RenewalType.none:
        nextRenewalDate = null;
        break;
      case RenewalType.daily:
        nextRenewalDate = DateTime(now.year, now.month, now.day + 1);
        break;
      case RenewalType.weekly:
        nextRenewalDate = DateTime(now.year, now.month, now.day + 7);
        break;
      case RenewalType.monthly:
        nextRenewalDate = DateTime(now.year, now.month + 1, now.day);
        break;
    }
  }

  bool shouldRenew() {
    if (renewalType == RenewalType.none || nextRenewalDate == null) {
      return false;
    }
    return DateTime.now().isAfter(nextRenewalDate!) || 
           DateTime.now().isAtSameMomentAs(nextRenewalDate!);
  }

  void renewTask() {
    if (renewalType != RenewalType.none) {
      isCompleted = false;
      lastRenewalDate = DateTime.now();
      _calculateNextRenewalDate();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'renewalType': renewalType.name,
      'lastRenewalDate': lastRenewalDate?.toIso8601String(),
      'nextRenewalDate': nextRenewalDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      renewalType: RenewalType.values.firstWhere(
        (e) => e.name == json['renewalType'],
        orElse: () => RenewalType.none,
      ),
      lastRenewalDate: json['lastRenewalDate'] != null
          ? DateTime.parse(json['lastRenewalDate'])
          : null,
      nextRenewalDate: json['nextRenewalDate'] != null
          ? DateTime.parse(json['nextRenewalDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    RenewalType? renewalType,
    DateTime? lastRenewalDate,
    DateTime? nextRenewalDate,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      renewalType: renewalType ?? this.renewalType,
      lastRenewalDate: lastRenewalDate ?? this.lastRenewalDate,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      createdAt: createdAt,
    );
  }

  String get formattedNextRenewal {
    if (nextRenewalDate == null) return 'No renewal scheduled';
    final formatter = DateFormat('MMM dd, yyyy');
    return 'Renews: ${formatter.format(nextRenewalDate!)}';
  }
}