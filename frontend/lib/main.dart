import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cleanpixel_ai/screens/splash_screen.dart';
import 'package:cleanpixel_ai/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0B0F19),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const CleanPixelApp());
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
