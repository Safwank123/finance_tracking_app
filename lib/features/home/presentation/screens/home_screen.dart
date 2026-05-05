import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../config/colors/app_colors.dart';
import '../../data/models/account_model.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/app_bar_actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: const [AppBarActions()],
      ),
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return _buildLoadingSkeleton();
            }

            if (state is HomeLoaded) {
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      context.read<HomeBloc>().add(LoadHomeData());
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSummary(state.transactions),
                                const SizedBox(height: 24),
                                Text(
                                  'Your Accounts',
                                  style: AppTypography.style20Bold.copyWith(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 16),
                                _AccountsListBuilder(accounts: state.accounts, selectedAccount: state.selectedAccount),
                                const SizedBox(height: 32),
                                _FiltersAndSearchBuilder(currentFilter: state.currentFilter),
                                const SizedBox(height: 16),
                                Text(
                                  'Transactions',
                                  style: AppTypography.style20Bold.copyWith(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state.transactions.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index >= state.transactions.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final transaction = state.transactions[index];
                                  final accountName = state.accounts
                                      .firstWhere((a) => a.id == transaction.accountId,
                                          orElse: () => const Account(id: '', name: 'Unknown'))
                                      .name;
                                  return _TransactionItemBuilder(
                                    transaction: transaction,
                                    accountName: accountName,
                                  );
                                },
                                childCount: state.transactions.length,
                              ),
                            ),
                          )
                        else
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'No transactions found.',
                                  style: AppTypography.style16Regular.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Loading overlay for filter/search
                  if (state.isLoadingFilters)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 300,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  height: 60,
                                  width: double.infinity,
                                  color: Colors.white,
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
      floatingActionButton: const _FloatingActionButtonBuilder(),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Accounts skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Transactions skeleton
            ...List.generate(5, (index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(List<TransactionModel> transactions) {
    double checkIn = 0;
    double checkOut = 0;

    for (var t in transactions) {
      if (t.type == 'INCOME') {
        checkIn += t.amount;
      } else {
        checkOut += t.amount;
      }
    }

    final balance = checkIn - checkOut;
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF3700B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Balance', style: AppTypography.style16Regular.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            formatter.format(balance),
            style: AppTypography.style32Bold.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Check-In', formatter.format(checkIn), Icons.arrow_downward, Colors.greenAccent),
              _buildSummaryItem('Check-Out', formatter.format(checkOut), Icons.arrow_upward, Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.style12Regular.copyWith(color: Colors.white70)),
            Text(amount, style: AppTypography.style16Bold.copyWith(color: Colors.white)),
          ],
        )
      ],
    );
  }
}

/// Separate widget to prevent unnecessary rebuilds of accounts list
class _AccountsListBuilder extends StatelessWidget {
  final List<Account> accounts;
  final Account? selectedAccount;

  const _AccountsListBuilder({
    required this.accounts,
    this.selectedAccount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length + 1,
        itemBuilder: (context, index) {
          if (index == accounts.length) {
            return GestureDetector(
              onTap: () => _showAddAccountDialog(context),
              child: _buildAddAccountCard(),
            );
          }
          final account = accounts[index];
          final isSelected = selectedAccount?.id == account.id;
          return GestureDetector(
            onTap: () {
              if (isSelected) {
                context.read<HomeBloc>().add(const AccountSelected(null));
              } else {
                context.read<HomeBloc>().add(AccountSelected(account));
              }
            },
            child: _buildAccountCard(account, isSelected),
          );
        },
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedColor = '#2196F3';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<HomeBloc>().add(AddAccount(name: nameController.text, colorCode: selectedColor));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountCard(Account account, bool isSelected) {
    final color = _colorFromHex(account.colorCode) ?? Colors.blue;
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha:0.2) : color.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : color.withValues(alpha:0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, color: color),
          const Spacer(),
          Text(
            account.name,
            style: AppTypography.style16SemiBold.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(account.balance),
            style: AppTypography.style18Bold.copyWith(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountCard() {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(
              'Add Account',
              style: AppTypography.style14SemiBold.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Color? _colorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

/// Separate widget for filters and search to prevent unnecessary rebuilds
class _FiltersAndSearchBuilder extends StatefulWidget {
  final String currentFilter;

  const _FiltersAndSearchBuilder({required this.currentFilter});

  @override
  State<_FiltersAndSearchBuilder> createState() => _FiltersAndSearchBuilderState();
}

class _FiltersAndSearchBuilderState extends State<_FiltersAndSearchBuilder> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (val) {
            context.read<HomeBloc>().add(SearchQueryChanged(val));
          },
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Today', 'Weekly', 'Monthly', 'Yearly'].map((filter) {
              final isSelected = widget.currentFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<HomeBloc>().add(FilterChanged(filter));
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Separate widget for transaction items to prevent unnecessary rebuilds
class _TransactionItemBuilder extends StatelessWidget {
  final TransactionModel transaction;
  final String accountName;

  const _TransactionItemBuilder({
    required this.transaction,
    required this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'INCOME';
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.withValues(alpha:0.1) : Colors.red.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(transaction.createdAt)} • $accountName',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// Separate widget for floating action button to prevent unnecessary rebuilds
class _FloatingActionButtonBuilder extends StatelessWidget {
  const _FloatingActionButtonBuilder();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final state = context.read<HomeBloc>().state;
        if (state is HomeLoaded && state.accounts.isNotEmpty) {
          _showAddTransactionDialog(context, state.accounts);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add an account first')),
          );
        }
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showAddTransactionDialog(BuildContext context, List<Account> accounts) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    bool isIncome = false;
    String selectedAccountId = accounts.first.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedAccountId,
                      items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                      onChanged: (val) {
                        setState(() => selectedAccountId = val!);
                      },
                      decoration: const InputDecoration(labelText: 'Account'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(isIncome ? 'Income' : 'Expense'),
                      value: isIncome,
                      onChanged: (val) => setState(() => isIncome = val),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Note (Optional)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (titleController.text.isNotEmpty && amount > 0) {
                      context.read<HomeBloc>().add(AddTransaction(
                            accountId: selectedAccountId,
                            title: titleController.text,
                            amount: amount,
                            note: noteController.text,
                            isIncome: isIncome,
                          ));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
