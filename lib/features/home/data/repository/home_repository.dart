import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';

class HomeRepository {
  final SupabaseClient _supabaseClient;

  HomeRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<Account>> getAccounts() async {
    final response = await _supabaseClient.from('accounts').select();
    
    List<Account> accounts = [];
    for (var row in response) {
      final balance = await _getAccountBalance(row['id']);
      accounts.add(Account.fromJson(row, balance: balance));
    }
    return accounts;
  }

  Future<double> _getAccountBalance(String accountId) async {
    final response = await _supabaseClient
        .from('transactions')
        .select('amount, type')
        .eq('account_id', accountId);

    double balance = 0.0;
    for (var row in response) {
      final amount = (row['amount'] as num).toDouble();
      if (row['type'] == 'INCOME') {
        balance += amount;
      } else {
        balance -= amount;
      }
    }
    return balance;
  }

  Future<void> createAccount(String name, String colorCode) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabaseClient.from('accounts').insert({
      'user_id': userId,
      'name': name,
      'color_code': colorCode,
    });
  }

  Future<List<TransactionModel>> getTransactions({
    String? accountId,
    String? searchQuery,
    String filter = 'All', 
  }) async {
    var query = _supabaseClient.from('transactions').select().order('created_at', ascending: false);

    if (accountId != null && accountId.isNotEmpty) {
      query = query.eq('account_id', accountId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final amountQuery = double.tryParse(searchQuery);
      if (amountQuery != null) {
        query = query.or('title.ilike.%$searchQuery%,note.ilike.%$searchQuery%,amount.eq.$amountQuery');
      } else {
        query = query.or('title.ilike.%$searchQuery%,note.ilike.%$searchQuery%');
      }
    }

    final response = await query;
    List<TransactionModel> transactions = response.map((json) => TransactionModel.fromJson(json)).toList();

    if (filter != 'All') {
      final now = DateTime.now();
      transactions = transactions.where((t) {
        if (filter == 'Today') {
          return t.createdAt.year == now.year &&
                 t.createdAt.month == now.month &&
                 t.createdAt.day == now.day;
        } else if (filter == 'Weekly') {
          final weekAgo = now.subtract(const Duration(days: 7));
          return t.createdAt.isAfter(weekAgo);
        } else if (filter == 'Monthly') {
          return t.createdAt.year == now.year && t.createdAt.month == now.month;
        } else if (filter == 'Yearly') {
          return t.createdAt.year == now.year;
        }
        return true;
      }).toList();
    }

    return transactions;
  }

  Future<void> addTransaction({
    required String accountId,
    required String title,
    String? note,
    required double amount,
    required bool isIncome,
  }) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabaseClient.from('transactions').insert({
      'user_id': userId,
      'account_id': accountId,
      'title': title,
      'note': note,
      'amount': amount,
      'type': isIncome ? 'INCOME' : 'EXPENSE',
    });
  }
}
