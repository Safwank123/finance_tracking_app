import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String accountId;
  final String title;
  final String? note;
  final double amount;
  final String type; 
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.title,
    this.note,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      title: json['title'] as String,
      note: json['note'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'title': title,
      'note': note,
      'amount': amount,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, accountId, title, note, amount, type, createdAt];
}
