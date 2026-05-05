import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String name;
  final String? colorCode;
  final double balance;

  const Account({
    required this.id,
    required this.name,
    this.colorCode,
    this.balance = 0.0,
  });

  factory Account.fromJson(Map<String, dynamic> json, {double balance = 0.0}) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      colorCode: json['color_code'] as String?,
      balance: balance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color_code': colorCode,
    };
  }

  @override
  List<Object?> get props => [id, name, colorCode, balance];
}
