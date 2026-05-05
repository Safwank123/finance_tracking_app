import 'package:equatable/equatable.dart';
import '../../data/models/account_model.dart';
import '../../data/models/transaction_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Account> accounts;
  final List<TransactionModel> transactions;
  final String currentFilter;
  final String searchQuery;
  final Account? selectedAccount;
  final bool isLoadingFilters;

  const HomeLoaded({
    required this.accounts,
    required this.transactions,
    this.currentFilter = 'All',
    this.searchQuery = '',
    this.selectedAccount,
    this.isLoadingFilters = false,
  });

  HomeLoaded copyWith({
    List<Account>? accounts,
    List<TransactionModel>? transactions,
    String? currentFilter,
    String? searchQuery,
    Account? selectedAccount,
    bool? isLoadingFilters,
  }) {
    return HomeLoaded(
      accounts: accounts ?? this.accounts,
      transactions: transactions ?? this.transactions,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedAccount: selectedAccount,
      isLoadingFilters: isLoadingFilters ?? this.isLoadingFilters,
    );
  }

  @override
  List<Object?> get props => [accounts, transactions, currentFilter, searchQuery, selectedAccount, isLoadingFilters];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
