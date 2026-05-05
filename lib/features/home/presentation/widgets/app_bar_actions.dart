import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
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
              onPressed: () async {
                if (state is HomeLoaded) {
                  if (state.transactions.isEmpty) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.warning,
                      style: ToastificationStyle.flatColored,
                      title: const Text('No transactions to export'),
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  try {
                    await PdfExportService.exportTransactionHistory(
                      state.selectedAccount,
                      state.transactions,
                      state.currentFilter,
                    );
                    if (context.mounted) {
                      toastification.show(
                        context: context,
                        type: ToastificationType.success,
                        style: ToastificationStyle.flatColored,
                        title: const Text('PDF Generated Successfully!'),
                        autoCloseDuration: const Duration(seconds: 3),
                        alignment: Alignment.bottomCenter,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      toastification.show(
                        context: context,
                        type: ToastificationType.error,
                        style: ToastificationStyle.flatColored,
                        title: const Text('Failed to generate PDF'),
                        description: Text(e.toString()),
                        autoCloseDuration: const Duration(seconds: 3),
                        alignment: Alignment.bottomCenter,
                      );
                    }
                  }
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
