import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import '../../../../config/colors/app_colors.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/utils/pdf_export_service.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class AppBarActions extends StatefulWidget {
  const AppBarActions({super.key});

  @override
  State<AppBarActions> createState() => _AppBarActionsState();
}

class _AppBarActionsState extends State<AppBarActions> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            if (previous is HomeLoaded && current is HomeLoaded) {
              return previous.transactions != current.transactions;
            }
            return current is HomeLoaded;
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Tooltip(
                message: "Export PDF",
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isExporting
                      ? null
                      : () async {
                          if (state is! HomeLoaded) return;

                          if (state.transactions.isEmpty) {
                            toastification.show(
                              context: context,
                              type: ToastificationType.warning,
                              title: const Text('No transactions to export'),
                              autoCloseDuration: const Duration(seconds: 3),
                            );
                            return;
                          }

                          setState(() => _isExporting = true);

                          try {
                            await PdfExportService.exportTransactionHistory(
                              state.selectedAccount,
                              state.transactions,
                              state.currentFilter,
                            );

                            if (!context.mounted) return;

                            toastification.show(
                              context: context,
                              type: ToastificationType.success,
                              style: ToastificationStyle.flatColored,
                              title: const Text('PDF Generated Successfully!'),
                              autoCloseDuration: const Duration(seconds: 3),
                              alignment: Alignment.bottomCenter,
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            toastification.show(
                              context: context,
                              type: ToastificationType.error,
                              style: ToastificationStyle.flatColored,
                              title: const Text('Failed to generate PDF'),
                              description: Text(e.toString()),
                              autoCloseDuration: const Duration(seconds: 3),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isExporting = false);
                            }
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.primary,
                          ),
                  ),
                ),
              ),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Tooltip(
            message: "Logout",
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _confirmLogout(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, color: AppColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Logout",
            style: AppTypography.style20Bold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: AppTypography.style16Regular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Cancel",
                style: AppTypography.style14SemiBold.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(LoggedOut());
              },
              child: const Text("Logout", style: AppTypography.style14SemiBold),
            ),
          ],
        );
      },
    );
  }
}
