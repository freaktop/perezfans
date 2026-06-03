import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'analytics_model.dart';
export 'analytics_model.dart';

class AnalyticsWidget extends StatefulWidget {
  const AnalyticsWidget({super.key});

  static String routeName = 'Analytics';
  static String routePath = 'analytics';

  @override
  State<AnalyticsWidget> createState() => _AnalyticsWidgetState();
}

class _AnalyticsWidgetState extends State<AnalyticsWidget> {
  late AnalyticsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AnalyticsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: const Center(child: Text('Sign in to see analytics.')),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: StreamBuilder<List<VideosRecord>>(
        stream: queryVideosRecord(
          queryBuilder: (videosRecord) =>
              videosRecord.where('video_user', isEqualTo: myRef),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Could not load analytics data.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final videos = snapshot.data!;
          final totalVideos = videos.length;
          final totalLikes = videos.fold<int>(
              0, (sum, v) => sum + v.videoLikes.length);

          return StreamBuilder<UsersRecord>(
            stream: UsersRecord.getDocument(myRef),
            builder: (context, userSnapshot) {
              final followers = userSnapshot.data?.followers.length ?? 0;

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildMetricCard(
                    context,
                    'Total Videos',
                    formatNumber(
                      totalVideos,
                      formatType: FormatType.compact,
                    ),
                    Icons.videocam,
                  ),
                  const SizedBox(height: 12.0),
                  _buildMetricCard(
                    context,
                    'Total Likes Received',
                    formatNumber(
                      totalLikes,
                      formatType: FormatType.compact,
                    ),
                    Icons.favorite,
                  ),
                  const SizedBox(height: 12.0),
                  _buildMetricCard(
                    context,
                    'Followers',
                    formatNumber(
                      followers,
                      formatType: FormatType.compact,
                    ),
                    Icons.people,
                  ),
                  const SizedBox(height: 24.0),
                  _buildEarningsCard(context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: FlutterFlowTheme.of(context).primary,
              size: 32.0,
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(),
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.poppins(),
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 32.0,
                ),
                const SizedBox(width: 16.0),
                Text(
                  'Earnings',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.poppins(),
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Connect Stripe to see earnings',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(),
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
