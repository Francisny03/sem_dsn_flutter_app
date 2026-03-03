import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_padding.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/pages/home/home_page.dart';
import 'package:sem_dsn/widget/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, -MediaQuery.of(context).size.height * 0.15),
              child: Image.asset(AppAssets.welcome3, fit: BoxFit.contain),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primaryColor.withValues(alpha: 0.4),
                    AppColors.primaryColor.withValues(alpha: 1),
                    AppColors.primaryColor.withValues(alpha: 1),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: true,
            bottom: true,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: Hero(
                      tag: 'app_logo',
                      child: Material(
                        color: Colors.transparent,
                        child: SvgPicture.asset(
                          AppAssets.logoApp,
                          width: 40,
                          height: 40,
                          colorFilter: const ColorFilter.mode(
                            AppColors.whiteTextColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: AppPadding.horizontalPadding20,
                    child: Column(
                      children: [
                        const Spacer(),
                        Padding(
                          padding: AppPadding.horizontalPadding20,
                          child: Text(
                            AppStrings.welcomeHeroText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.whiteTextColor,
                              fontSize: AppFontSizes.welcomeHeroText,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Padding(
                          padding: AppPadding.horizontalPadding28,
                          child: StadiumButton(
                            value: AppStrings.continueButton,
                            type: BtnType.white,
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder<void>(
                                  pageBuilder: (_, __, ___) => const HomePage(),
                                  transitionDuration: const Duration(
                                    milliseconds: 800,
                                  ),
                                  reverseTransitionDuration: const Duration(
                                    milliseconds: 400,
                                  ),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
