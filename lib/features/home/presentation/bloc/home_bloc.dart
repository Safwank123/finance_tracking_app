import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  HomeBloc({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<FilterChanged>(_onFilterChanged);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<AccountSelected>(_onAccountSelected);
    on<AddTransaction>(_onAddTransaction);
    on<AddAccount>(_onAddAccount);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final accounts = await _homeRepository.getAccounts();
      final transactions = await _homeRepository.getTransactions();
      emit(HomeLoaded(accounts: accounts, transactions: transactions));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onFilterChanged(FilterChanged event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // Do not emit HomeLoading() here to avoid wiping the screen
      try {
        final transactions = await _homeRepository.getTransactions(
          accountId: currentState.selectedAccount?.id,
          searchQuery: currentState.searchQuery,
          filter: event.filter,
        );
        emit(currentState.copyWith(transactions: transactions, currentFilter: event.filter, selectedAccount: currentState.selectedAccount));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    }
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // Do not emit HomeLoading() here to avoid wiping the screen
      try {
        final transactions = await _homeRepository.getTransactions(
          accountId: currentState.selectedAccount?.id,
          searchQuery: event.query,
          filter: currentState.currentFilter,
        );
        emit(currentState.copyWith(transactions: transactions, searchQuery: event.query, selectedAccount: currentState.selectedAccount));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    }
  }

  Future<void> _onAccountSelected(AccountSelected event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // Do not emit HomeLoading() here to avoid wiping the screen
      try {
        final transactions = await _homeRepository.getTransactions(
          accountId: event.account?.id,
          searchQuery: currentState.searchQuery,
          filter: currentState.currentFilter,
        );
        // Emit new state with updated transactions
        emit(HomeLoaded(
          accounts: currentState.accounts,
          transactions: transactions,
          currentFilter: currentState.currentFilter,
          searchQuery: currentState.searchQuery,
          selectedAccount: event.account,
          isLoadingFilters: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingFilters: false));
        emit(HomeError(e.toString()));
      }
    }
  }

  Future<void> _onAddTransaction(AddTransaction event, Emitter<HomeState> emit) async {
    try {
      await _homeRepository.addTransaction(
        accountId: event.accountId,
        title: event.title,
        note: event.note,
        amount: event.amount,
        isIncome: event.isIncome,
      );
      add(LoadHomeData()); // Reload everything after adding
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onAddAccount(AddAccount event, Emitter<HomeState> emit) async {
    try {
      await _homeRepository.createAccount(event.name, event.colorCode);
      add(LoadHomeData()); // Reload everything after adding
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
