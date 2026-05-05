import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'config/network/network_bloc.dart';
import 'features/auth/data/repository/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/data/repository/home_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://pafsvxwktalbixpgprft.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhZnN2eHdrdGFsYml4cGdwcmZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5NzUyNjksImV4cCI6MjA5MzU1MTI2OX0.cZFxkAVwk_nZdlm2dV7mnSNm2u4tBBxVl8rSdiq1Qsw',
  );

  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NetworkBloc>(
          create: (context) => NetworkBloc(connectivity: Connectivity()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(homeRepository: HomeRepository()),
        ),
      ],
      child: ToastificationWrapper(
        child: BlocListener<NetworkBloc, NetworkState>(
          listener: (context, state) {
            if (!state.isConnected) {
              toastification.show(
                context: context,
                type: ToastificationType.error,
                style: ToastificationStyle.flatColored,
                title: const Text('You are offline'),
                description: const Text('Please check your internet connection.'),
                alignment: Alignment.topCenter,
                autoCloseDuration: const Duration(seconds: 4),
                icon: const Icon(Icons.wifi_off),
              );
            } else if (state.isRestored) {
              toastification.show(
                context: context,
                type: ToastificationType.success,
                style: ToastificationStyle.flatColored,
                title: const Text('Back online'),
                description: const Text('Internet connection restored.'),
                alignment: Alignment.topCenter,
                autoCloseDuration: const Duration(seconds: 3),
                icon: const Icon(Icons.wifi),
              );
            }
          },
          child: MaterialApp(
            title: 'Finance Tracker',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: RouteNames.splash.name,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        ),
      ),
    );
  }
}

