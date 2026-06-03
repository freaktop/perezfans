import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trending_model.dart';
export 'trending_model.dart';

class TrendingWidget extends StatefulWidget {
  const TrendingWidget({super.key});

  static String routeName = 'Trending';
  static String routePath = 'trending';

  @override
  State<TrendingWidget> createState() => _TrendingWidgetState();
}

class _TrendingWidgetState extends State<TrendingWidget> {
  late TrendingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TrendingModel());

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
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: true,
          title: Text(
            'Trending',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(),
                  letterSpacing: 0.0,
                ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: VideoHashtagsRecord.collection
              .orderBy('video_count', descending: true)
              .limit(50)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Could not load trending hashtags.',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No trending hashtags yet.\nHashtags appear when users post videos with them.',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final raw = docs[i].data();
                final data =
                    raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                final hashtag = (data['hashtag'] ?? '').toString();
                final videoCount = (data['video_count'] as num?)?.toInt() ?? 0;
                return ListTile(
                  leading: Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        '#',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                      ),
                    ),
                  ),
                  title: Text(
                    '#$hashtag',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                  ),
                  subtitle: Text(
                    '$videoCount ${videoCount == 1 ? 'video' : 'videos'}',
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                  onTap: () {
                    context.pushNamed(
                      SearchWidget.routeName,
                      queryParameters: {
                        'q': hashtag,
                      }.withoutNulls,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
