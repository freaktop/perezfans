import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tutorial_model.dart';
export 'app_tutorial_model.dart';

class AppTutorialWidget extends StatefulWidget {
  const AppTutorialWidget({super.key});

  static String routeName = 'AppTutorial';
  static String routePath = 'app-tutorial';

  @override
  State<AppTutorialWidget> createState() => _AppTutorialWidgetState();
}

class _AppTutorialWidgetState extends State<AppTutorialWidget> {
  late AppTutorialModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_TutorialCard> _cards = const [
    _TutorialCard(
      icon: Icons.waving_hand,
      title: 'Welcome to PerezFans',
      description:
          'The ultimate live streaming & content platform. Catch it live!',
    ),
    _TutorialCard(
      icon: Icons.live_tv,
      title: 'Live Streaming',
      description:
          'Go live anytime. Your fans can join, chat, and tip you in real-time.',
    ),
    _TutorialCard(
      icon: Icons.monetization_on,
      title: 'Monetize Your Content',
      description:
          'Set up subscriptions, receive tips, and offer exclusive content to your fans.',
    ),
    _TutorialCard(
      icon: Icons.vpn_lock,
      title: 'Vault Requests',
      description:
          'Fans can request custom content. You choose what to create and earn from it.',
    ),
    _TutorialCard(
      icon: Icons.verified_user,
      title: 'Stay Safe',
      description:
          'We enforce age verification and community guidelines to keep everyone safe.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppTutorialModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          title: Text(
            'App Tutorial',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(),
                  letterSpacing: 0.0,
                ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _model.pageController,
                  onPageChanged: (page) {
                    safeSetState(() => _model.currentPage = page);
                  },
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isLast = index == _cards.length - 1;
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            card.icon,
                            size: 80.0,
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                          const SizedBox(height: 32.0),
                          Text(
                            card.title,
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  font: GoogleFonts.poppins(),
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            card.description,
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  font: GoogleFonts.poppins(),
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 32.0),
                          FFButtonWidget(
                            onPressed: () async {
                              if (isLast) {
                                context.pushReplacementNamed('Home');
                              } else {
                                _model.pageController?.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            text: isLast ? 'Get Started' : 'Next',
                            options: FFButtonOptions(
                              width: 200.0,
                              height: 48.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _cards.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _model.currentPage == index ? 24.0 : 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: _model.currentPage == index
                            ? FlutterFlowTheme.of(context).primary
                            : FlutterFlowTheme.of(context).secondaryText,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialCard {
  final IconData icon;
  final String title;
  final String description;

  const _TutorialCard({
    required this.icon,
    required this.title,
    required this.description,
  });
}
