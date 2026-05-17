import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/utils/font_utility.dart';
import '../../bloc/welcome/welcome_cubit.dart';
import '../../bloc/welcome/welcome_state.dart';
import '../../core/routes.dart';
import '../../core/controllers/ui_store_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WelcomeCubit(
        prefs: context.read<SharedPreferences>(),
        controller: context.read<UiStoreController>(),
      ),
      child: Scaffold(
      body: Row(
        children: [
          // Left Side - Branding / Graphic
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8E2DE2),
                    Color(0xFF4A00E0),
                  ],
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
                  child: BlocConsumer<WelcomeCubit, WelcomeState>(
                      listener: (context, state) {
                        if (state.isSuccess) {
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        }
                      },
                    builder: (context, state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.welcomeGetStarted,
                            style: FontUtility.heading.copyWith(
                              color: const Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.welcomeAuthPrompt,
                            style: FontUtility.body.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 48),
                          if (state.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: FontUtility.body.copyWith(color: Colors.red.shade700, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                            Text(
                              AppLocalizations.of(context)!.welcomeEnterOrgCode,
                              style: FontUtility.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              keyboardType: TextInputType.text,
                              onChanged: (value) =>
                                  context.read<WelcomeCubit>().organizationNameChanged(value),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.welcomeOrgCodeHint,
                               hintStyle: FontUtility.body.copyWith(color: Colors.black38),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF4A00E0), width: 2),
                              ),
                            ),
                            style: FontUtility.body,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: state.isValid && !state.isLoading
                                  ? () => context.read<WelcomeCubit>().submit()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A00E0),
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: state.isValid ? 5 : 0,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: state.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'Submit',
                                        style: FontUtility.button.copyWith(
                                          color: state.isValid
                                              ? Colors.white
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
