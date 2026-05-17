import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/font_utility.dart';
import '../../bloc/sign_in/sign_in_cubit.dart';
import '../../bloc/sign_in/sign_in_state.dart';
import 'forgot_password_screen.dart';
import '../../core/routes.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SignInCubit(prefs: context.read<SharedPreferences>()),
      child: Scaffold(
        body: Row(
          children: [
            // Left Side - Branding / Graphic
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          AppLocalizations.of(context)!.welcomeUnlockBusiness,
                          style: FontUtility.heading.copyWith(
                            color: Colors.white,
                            fontSize: 42,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.welcomeDescription,
                          style: FontUtility.body.copyWith(
                            color: Colors.white70,
                            fontSize: 18,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Right Side - Action Area
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                    child: BlocConsumer<SignInCubit, SignInState>(
                      listener: (context, state) {
                        if (state.isSuccess) {
                          if (state.navigateToHome) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.home,
                            );
                          } else {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.storeList,
                            );
                          }
                        }
                      },
                      builder: (context, state) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.signInWelcome,
                                textAlign: TextAlign.center,
                                style: FontUtility.heading.copyWith(
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Icon(
                                Icons.business_center,
                                size: 64,
                                color: Color(0xFF4A00E0),
                              ),
                              const SizedBox(height: 48),
                              if (state.errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          state.errorMessage!,
                                          style: FontUtility.body.copyWith(
                                            color: Colors.red.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              Text(
                                AppLocalizations.of(context)!.signInEmailPhone,
                                style: FontUtility.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                onChanged: (value) => context
                                    .read<SignInCubit>()
                                    .identifierChanged(value),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.signInEmailPhoneHint,
                                  hintStyle: FontUtility.body.copyWith(
                                    color: Colors.black38,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4A00E0),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: FontUtility.body,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppLocalizations.of(context)!.signInPassword,
                                style: FontUtility.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                onChanged: (value) => context
                                    .read<SignInCubit>()
                                    .passwordChanged(value),
                                obscureText: state.obscurePassword,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.signInPasswordHint,
                                  hintStyle: FontUtility.body.copyWith(
                                    color: Colors.black38,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4A00E0),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: FontUtility.body,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: !state.obscurePassword,
                                          onChanged: (_) => context
                                              .read<SignInCubit>()
                                              .togglePasswordVisibility(),
                                          activeColor: const Color(0xFF4A00E0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => context
                                            .read<SignInCubit>()
                                            .togglePasswordVisibility(),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.signInShowPassword,
                                          style: FontUtility.body.copyWith(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.signInForgotPasswordPrompt,
                                      style: FontUtility.body.copyWith(
                                        color: const Color(0xFF4A00E0),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: state.isValid && !state.isLoading
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF8E2DE2),
                                            Color(0xFF4A00E0),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : null,
                                  color: state.isValid && !state.isLoading
                                      ? null
                                      : Colors.grey.shade300,
                                  boxShadow: state.isValid && !state.isLoading
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF4A00E0,
                                            ).withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: state.isValid && !state.isLoading
                                        ? () => context
                                              .read<SignInCubit>()
                                              .submit()
                                        : null,
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: state.isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.signInButton,
                                                style: FontUtility.button
                                                    .copyWith(
                                                      color: state.isValid
                                                          ? Colors.white
                                                          : Colors
                                                                .grey
                                                                .shade500,
                                                    ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
