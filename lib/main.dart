
import 'package:chess_park/providers/connectivity_provider.dart';
import 'package:chess_park/providers/live_game_provider.dart';
import 'package:chess_park/providers/server_time_provider.dart';
import 'package:chess_park/providers/settings_provider.dart';
import 'package:chess_park/providers/bot_game_provider.dart';
import 'package:chess_park/screens/verify_email_screen.dart';
import 'package:chess_park/services/game_repository.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/theme/app_constants.dart';
import 'package:chess_park/widgets/network_aware_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chess_park/firebase_options.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:chess_park/screens/auth_screen.dart';
import 'package:chess_park/screens/home_screen.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);


 if (Firebase.apps.isEmpty) {

     await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
 );}

  if (kDebugMode) {
    try {
       final String host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
      print("Connecting to local emulators");
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
      await FirebaseStorage.instance.useStorageEmulator(host, 9199);
      print("Connected to local Firebase emulators.");
    } catch (e) {
      print("Failed to connect to emulators: $e");
    }
  }

  final settingsProvider = SettingsProvider();
  final serverTimeProvider = ServerTimeProvider();
  final connectivityProvider = ConnectivityProvider();

  if (!kDebugMode) {
    await Future.wait([
      connectivityProvider.initialize(),
      serverTimeProvider.initialize(),
    ]);
  } else {

    await connectivityProvider.initialize();
  }
  runApp(ChessPark(
    settingsProvider: settingsProvider,
    serverTimeProvider: serverTimeProvider,
    connectivityProvider: connectivityProvider,
  ));
}
class ChessPark extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final ServerTimeProvider serverTimeProvider;
  final ConnectivityProvider connectivityProvider;

  const ChessPark({
    super.key,
    required this.settingsProvider,
    required this.serverTimeProvider,
    required this.connectivityProvider,
  });

  @override
  Widget build(BuildContext context) {
    final GameRepository gameRepository = GameRepository();
    final FirestoreService firestoreService = FirestoreService();

    return MultiProvider(
      providers: [
        Provider<GameRepository>.value(value: gameRepository),
        Provider<FirestoreService>.value(value: firestoreService),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<ServerTimeProvider>.value(value: serverTimeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider(settingsProvider: settingsProvider)),
        ChangeNotifierProvider(create: (_) => LiveGamesProvider(firestoreService: firestoreService)),
        ChangeNotifierProvider<ConnectivityProvider>.value(value: connectivityProvider),
        ChangeNotifierProvider(create: (_) => BotGameProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.darkTheme,
        home: const NetworkAwareWidget(
          child: AuthWrapper(),
        ),
      ),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>().authState;


    const loadingView = Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.backgroundDecoration,
        child: Center(child: CircularProgressIndicator(color: AppTheme.kColorAccent))
      )
    );

    switch (authState) {
      case AuthState.unauthenticated:
        return const AuthScreen();
      case AuthState.emailNotVerified:
        return const VerifyEmailScreen();
      case AuthState.authenticated:
        final settingsLoaded = context.watch<SettingsProvider>().isLoaded;
        if (settingsLoaded) {
          return const HomeScreen();
        } else {
          return loadingView;
        }
      case AuthState.loading:
        return loadingView;
    }
  }
}