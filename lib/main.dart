import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform, Directory;
import 'package:path_provider/path_provider.dart';

// sqflite FFI initialization for desktop (macOS, Linux, Windows)
// ensures sqlite databases can be opened when running outside mobile.
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/splash/splash_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'core/localization/l10n/app_localizations.dart';
import 'presentation/screens/splash_screen.dart';
import 'core/routes.dart';
import 'presentation/widgets/device_restriction_wrapper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'bloc/language/language_bloc.dart';
import 'bloc/language/language_state.dart';
import 'core/utils/font_utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/service_locator.dart';
import 'features/store/presentation/bloc/store_bloc.dart';
import 'core/controllers/ui_store_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI on desktop platforms so sqlite can open DB files.
  // This must run before any database access performed by downstream
  // libraries (for example pos_orders_offline) so they pick up the ffi
  // database factory.
  try {
    if (!Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      // set the global factory used by sqflite_common
      databaseFactory = databaseFactoryFfi;
      
      // Ensure a writable directory exists for SQLite database files.
      // Try multiple paths, falling back to temp directory if needed.
      bool dirCreated = false;
      
      // First, try to use the system temp directory (most reliable)
      try {
        final tempDir = Directory.systemTemp.path;
        final appDir = Directory('$tempDir/pos_tablet_db');
        if (!appDir.existsSync()) {
          appDir.createSync(recursive: true);
        }
        dirCreated = true;
      } catch (e) {
        // Temp directory creation failed, try application documents directory
        try {
          final appDocsDir = await getApplicationDocumentsDirectory();
          // Validate the path is not root or system directory
          if (appDocsDir.path != '/' && !appDocsDir.path.startsWith('/.')) {
            if (!appDocsDir.existsSync()) {
              appDocsDir.createSync(recursive: true);
            }
            dirCreated = true;
          }
        } catch (_) {
          // Both attempts failed, but we continue anyway.
          // The database operations may still work or have their own fallbacks.
        }
      }
    }
  } catch (_) {
    // If sqflite_ffi isn't available or initialization fails, we continue
    // and let the downstream code handle errors. Avoid crashing the app
    // during initialization.
  }

  // Initialize SharedPreferences for app-wide access
  final prefs = await SharedPreferences.getInstance();

  // Initialize service locator and register singletons
  await initServiceLocator(prefs: prefs);

  // Lock the orientation to Landscape only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(PosTabletApp(prefs: prefs));
  });
}

class PosTabletApp extends StatelessWidget {
  final SharedPreferences prefs;

  const PosTabletApp({required this.prefs, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>(
          create: (context) => prefs,
        ),
        RepositoryProvider<UiStoreController>(
          create: (context) => getIt<UiStoreController>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SplashBloc>(
            create: (context) => SplashBloc(),
          ),
          BlocProvider<LanguageBloc>(
            create: (context) => LanguageBloc(),
          ),
           BlocProvider<UserBloc>(
             create: (context) => UserBloc(),
           ),
           // Provide the global StoreBloc from the service locator so every
           // widget can access app-level store state.
           BlocProvider<StoreBloc>(
             create: (context) => getIt<StoreBloc>(),
           ),
        ],
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, languageState) {
            return MaterialApp(
              title: 'NexPOS Tablet',
              debugShowCheckedModeBanner: false,
              locale: languageState.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ta'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A00E0)),
                useMaterial3: true,
                textTheme: TextTheme(
                  headlineMedium: FontUtility.heading,
                  bodyMedium: FontUtility.body,
                ),
              ),
              builder: (context, child) {
                // Wrap the entire app with the device restriction widget
                // This ensures that on small screens, the user is forcefully blocked.
                return DeviceRestrictionWrapper(
                  child: child ?? const SizedBox(),
                );
              },
              // Register named routes for navigation across the app. The splash
              // screen remains the initial entry point (home) and can navigate
              // using the named routes defined in AppRoutes.
              routes: AppRoutes.routes,
              onGenerateRoute: AppRoutes.generate,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
