import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/splash/splash_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/widgets/device_restriction_wrapper.dart';
import 'core/utils/font_utility.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the orientation to Landscape only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const PosTabletApp());
  });
}

class PosTabletApp extends StatelessWidget {
  const PosTabletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>(
          create: (context) => SplashBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'NexPOS Tablet',
        debugShowCheckedModeBanner: false,
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
        home: const SplashScreen(),
      ),
    );
  }
}
