import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cleanpixel_ai/screens/splash_screen.dart';
import 'package:cleanpixel_ai/services/locale_service.dart';
import 'package:cleanpixel_ai/services/theme_service.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Crash Interceptor for Flutter UI Errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('ZeroCrash Interceptor caught UI error: ${details.exception}');
    };

    // Custom Graceful Error Widget
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: const Color(0xFFFDF2F8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFFEC4899), size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CleanPixel AI is restoring view...',
                  style: TextStyle(color: Color(0xFF831843), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    };

    // Initialize services
    await LocaleService.init();
    await ThemeService.init();

    // Immersive system UI overlay with White & Pink styling
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    runApp(const CleanPixelApp());
  }, (error, stack) {
    debugPrint('ZeroCrash Zone caught async exception: $error\n$stack');
  });
}

class CleanPixelApp extends StatelessWidget {
  const CleanPixelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LocaleService.currentLocale,
          builder: (context, localeCode, _) {
            return MaterialApp(
              title: 'CleanPixel AI',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              // 🌸 Sleek Luxury White & Rose Pink Theme
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFFAF5FF),
                cardColor: Colors.white,
                primaryColor: const Color(0xFFEC4899),
                textTheme: GoogleFonts.plusJakartaSansTextTheme(
                  ThemeData(brightness: Brightness.light).textTheme,
                ),
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFEC4899),
                  secondary: Color(0xFFF43F5E),
                  surface: Colors.white,
                  surfaceTint: Color(0xFFFDF2F8),
                  onPrimary: Colors.white,
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Color(0xFF1E293B)),
                  titleTextStyle: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: _CleanPixelPageTransition(),
                    TargetPlatform.iOS: _CleanPixelPageTransition(),
                  },
                ),
              ),
              // 🌸 Deep Velvet Night & Neon Pink Theme
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF0F0715),
                cardColor: const Color(0xFF1B0C24),
                primaryColor: const Color(0xFFEC4899),
                textTheme: GoogleFonts.plusJakartaSansTextTheme(
                  ThemeData(brightness: Brightness.dark).textTheme,
                ),
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFEC4899),
                  secondary: Color(0xFFF43F5E),
                  surface: Color(0xFF1B0C24),
                  surfaceTint: Color(0xFF2D123A),
                  onPrimary: Colors.white,
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF0F0715),
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.white),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: _CleanPixelPageTransition(),
                    TargetPlatform.iOS: _CleanPixelPageTransition(),
                  },
                ),
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}

class _CleanPixelPageTransition extends PageTransitionsBuilder {
  const _CleanPixelPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(begin: const Offset(0.0, 0.04), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));
    final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOut));

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      ),
    );
  }
}
