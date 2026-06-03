import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/i18n/translation_service.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_model.dart';
export 'settings_model.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late SettingsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Widget _settingsItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(0.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding:
                EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 20.0, 0.0),
                  child: Icon(
                    icon,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24.0,
                  ),
                ),
                Text(
                  label,
                  style: FlutterFlowTheme.of(context)
                      .titleMedium
                      .override(
                        font: GoogleFonts.poppins(
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (ctx) {
        final current = FlutterFlowTheme.themeMode;
        return SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  'App Theme',
                  style: FlutterFlowTheme.of(context).titleLarge,
                ),
                SizedBox(height: 20.0),
                _themeOption(ctx, 'System', ThemeMode.system, current),
                _themeOption(ctx, 'Light', ThemeMode.light, current),
                _themeOption(ctx, 'Dark', ThemeMode.dark, current),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (ctx) {
        final currentLocale = TranslationService().currentLocale;
        return SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  'App Language',
                  style: FlutterFlowTheme.of(context).titleLarge,
                ),
                SizedBox(height: 20.0),
                _langOption(ctx, 'English', 'en', currentLocale),
                _langOption(ctx, 'Español', 'es', currentLocale),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _langOption(
      BuildContext context, String label, String locale, String currentLocale) {
    final selected = locale == currentLocale;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () {
          TranslationService().setLocale(locale);
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: selected
                ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                : FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: selected
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).lineColor,
              width: selected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
              Spacer(),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: FlutterFlowTheme.of(context).primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOption(
      BuildContext context, String label, ThemeMode mode, ThemeMode current) {
    final selected = mode == current;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () {
          setDarkModeSetting(context, mode);
          FlutterFlowTheme.saveThemeMode(mode);
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: selected
                ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                : FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: selected
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).lineColor,
              width: selected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                mode == ThemeMode.system
                    ? Icons.settings_brightness
                    : mode == ThemeMode.light
                        ? Icons.light_mode
                        : Icons.dark_mode,
                color: selected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).primaryText,
              ),
              SizedBox(width: 16.0),
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
              Spacer(),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: FlutterFlowTheme.of(context).primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 460.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
              child: Container(
                width: 50.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _settingsItem(
                    context,
                    icon: Icons.live_tv,
                    label: 'Creator Hub',
                    onTap: () => context.pushNamed(CreatorHubWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.grid_view,
                    label: 'Live Grid',
                    onTap: () => context.pushNamed(LiveGridWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.schedule,
                    label: 'Schedule Stream',
                    onTap: () =>
                        context.pushNamed(ScheduleStreamWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.upcoming,
                    label: 'Upcoming Streams',
                    onTap: () =>
                        context.pushNamed(UpcomingStreamsWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.explore,
                    label: 'Explore',
                    onTap: () => context.pushNamed(ExploreWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.trending_up,
                    label: 'Trending',
                    onTap: () => context.pushNamed(TrendingWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.search,
                    label: 'Search',
                    onTap: () => context.pushNamed(SearchWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    label: 'Wallet & Earnings',
                    onTap: () => context.pushNamed(WalletWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.card_giftcard,
                    label: 'Affiliate Program',
                    onTap: () =>
                        context.pushNamed(AffiliateWidget.routeName),
                  ),
                  if (currentUserDocument?.role == 'admin')
                    _settingsItem(
                      context,
                      icon: Icons.shield,
                      label: 'Admin Panel',
                      onTap: () =>
                          context.pushNamed(AdminPanelWidget.routeName),
                    ),
                  _settingsItem(
                    context,
                    icon: Icons.lock,
                    label: 'Age Verification',
                    onTap: () =>
                        context.pushNamed(AgeVerificationWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.notifications,
                    label: 'Notification Preferences',
                    onTap: () => context.pushNamed(
                        NotificationPreferencesWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.report,
                    label: 'Report',
                    onTap: () => context.pushNamed(ReportWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.palette,
                    label: 'Theme',
                    onTap: () => _showThemePicker(context),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.language,
                    label: 'Language',
                    onTap: () => _showLanguagePicker(context),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.school,
                    label: 'App Tutorial',
                    onTap: () =>
                        context.pushNamed(AppTutorialWidget.routeName),
                  ),
                  if (!currentUserEmailVerified)
                    _settingsItem(
                      context,
                      icon: Icons.verified_user,
                      label: 'Verify Email',
                      onTap: () async {
                        await currentUser?.sendEmailVerification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Verification email sent! Check your inbox.'),
                            ),
                          );
                        }
                      },
                    ),
                  _settingsItem(
                    context,
                    icon: Icons.description,
                    label: 'Terms of Service',
                    onTap: () =>
                        context.pushNamed(TermsOfServiceWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.privacy_tip,
                    label: 'Privacy Policy',
                    onTap: () =>
                        context.pushNamed(PrivacyPolicyWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.person_off,
                    label: 'Blocked Users',
                    onTap: () =>
                        context.pushNamed(BlockedUsersWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.delete_forever,
                    label: 'Delete Account',
                    onTap: () =>
                        context.pushNamed(DeleteAccountWidget.routeName),
                  ),
                  _settingsItem(
                    context,
                    icon: Icons.logout,
                    label: 'Log Out',
                    onTap: () async {
                      GoRouter.of(context).prepareAuthEvent();
                      await authManager.signOut();
                      GoRouter.of(context).clearRedirectLocation();
                      context.goNamedAuth(
                          WelcomeWidget.routeName, context.mounted);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
