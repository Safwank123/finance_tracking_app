import 'package:equatable/equatable.dart';
import '../../data/models/account_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class FilterChanged extends HomeEvent {
  final String filter;

  const FilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchQueryChanged extends HomeEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class AccountSelected extends HomeEvent {
  final Account? account;

  const AccountSelected(this.account);

  @override
  List<Object?> get props => [account];
}

class AddTransaction extends HomeEvent {
  final String accountId;
  final String title;
  final String? note;
  final double amount;
  final bool isIncome;

  const AddTransaction({
    required this.accountId,
    required this.title,
    this.note,
    required this.amount,
    required this.isIncome,
  });

  @override
  List<Object?> get props => [accountId, title, note, amount, isIncome];
}

class AddAccount extends HomeEvent {
  final String name;
  final String colorCode;

  const AddAccount({required this.name, required this.colorCode});

  @override
  List<Object?> get props => [name, colorCode];
}
