import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/pdf_export_service.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Separate widget for AppBar actions to prevent unnecessary rebuilds
class AppBarActions extends StatelessWidget {
  const AppBarActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            // Only rebuild when transactions change
            if (previous is HomeLoaded && current is HomeLoaded) {
              return previous.transactions != current.transactions;
            }
            return current is HomeLoaded;
          },
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                if (state is HomeLoaded) {
                  if (state.transactions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No transactions to export')),
                    );
                    return;
                  }
                  PdfExportService.exportTransactionHistory(
                    state.selectedAccount,
                    state.transactions,
                    state.currentFilter,
                  );
                }
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.read<AuthBloc>().add(LoggedOut());
          },
        ),
      ],
    );
  }
}
