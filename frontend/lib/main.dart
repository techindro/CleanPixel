import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cleanpixel_ai/screens/splash_screen.dart';
import 'package:cleanpixel_ai/services/locale_service.dart';

void main() async {
  // Global Unhandled Async Error Zone (Prevents any crash from escaping to the OS)
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Crash Interceptor for Flutter UI Errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('ZeroCrash Interceptor caught UI error: ${details.exception}');
    };

    // 2. Custom Graceful Error Widget (Never show red crash screen to user)
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF38BDF8), size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CleanPixel AI is restoring view...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    };

    // Initialize locale service
    await LocaleService.init();

    // Immersive system UI overlay
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F19),
      systemNavigationBarIconBrightness: Brightness.light,
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
    return ValueListenableBuilder<String>(
      valueListenable: LocaleService.currentLocale,
      builder: (context, localeCode, _) {
        return MaterialApp(
          title: 'CleanPixel AI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              secondary: Color(0xFF2563EB),
              surface: Color(0xFF1E293B),
            ),
            splashColor: const Color(0xFF38BDF8).withValues(alpha: 0.12),
            highlightColor: const Color(0xFF38BDF8).withValues(alpha: 0.06),
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
