import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/pages/splashscreen.dart';
import 'package:sem_dsn/providers/articles_provider.dart';
import 'package:sem_dsn/providers/books_provider.dart';
import 'package:sem_dsn/providers/categories_provider.dart';
import 'package:sem_dsn/providers/press_articles_cache_provider.dart';
import 'package:sem_dsn/services/read_articles_service.dart';
import 'package:sem_dsn/services/selection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  await SelectionService.instance.loadFromDisk();
  await ReadArticlesService.instance.loadFromDisk();
  runApp(const SemDsnApp());
}

class SemDsnApp extends StatelessWidget {
  const SemDsnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SelectionService.instance),
        ChangeNotifierProvider.value(value: ReadArticlesService.instance),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ArticlesProvider()),
        ChangeNotifierProvider(create: (_) => BooksProvider()),
        ChangeNotifierProvider(create: (_) => PressArticlesCacheProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          useMaterial3: true,
          textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),
        ),
        home: const SplashScreen(),
        //home: const HomePage(),
      ),
    );
  }
}
