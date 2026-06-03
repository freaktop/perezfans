import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'explore_model.dart';
export 'explore_model.dart';

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  static String routeName = 'Explore';
  static String routePath = 'explore';

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget> {
  late ExploreModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_CategoryInfo> _categories = const [
    _CategoryInfo('TikTok', Icons.music_video),
    _CategoryInfo('Dance', Icons.accessibility_new),
    _CategoryInfo('Music', Icons.music_note),
    _CategoryInfo('Comedy', Icons.emoji_emotions),
    _CategoryInfo('Sports', Icons.sports_soccer),
    _CategoryInfo('Gaming', Icons.sports_esports),
    _CategoryInfo('Education', Icons.school),
    _CategoryInfo('Fitness', Icons.fitness_center),
    _CategoryInfo('Cooking', Icons.restaurant),
    _CategoryInfo('Art', Icons.palette),
    _CategoryInfo('Travel', Icons.flight),
    _CategoryInfo('Fashion', Icons.checkroom),
    _CategoryInfo('Live', Icons.live_tv),
    _CategoryInfo('Exclusive', Icons.star),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExploreModel());

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
            'Explore',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(),
                  letterSpacing: 0.0,
                ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                child: Text(
                  'Trending Categories',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.poppins(),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _categories.map((cat) {
                    return InkWell(
                      onTap: () {
                        context.pushNamed(
                          SearchWidget.routeName,
                          queryParameters: {
                            'q': cat.label,
                          }.withoutNulls,
                        );
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width / 4 - 20.0,
                        constraints: const BoxConstraints(maxWidth: 100.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat.icon,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 28.0,
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                cat.label,
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.poppins(),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              _suggestedUsersSection(context),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 8.0),
                child: Text(
                  'Trending Videos',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.poppins(),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: VideosRecord.collection
                    .orderBy('video_comment_num', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Could not load trending videos.',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
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
                          'No trending videos yet.',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final raw = docs[i].data();
                      final data = raw is Map<String, dynamic>
                          ? raw
                          : <String, dynamic>{};
                      final videoUserRef =
                          data['video_user'] as DocumentReference?;
                      final description =
                          (data['video_description'] ?? '').toString();
                      return StreamBuilder<UsersRecord>(
                        stream: videoUserRef != null
                            ? UsersRecord.getDocument(videoUserRef)
                            : null,
                        builder: (context, u) {
                          final userName = u.data?.displayName.isNotEmpty == true
                              ? u.data!.displayName
                              : 'User';
                          return ListTile(
                            leading: Container(
                              width: 60.0,
                              height: 80.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  child: Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: FlutterFlowTheme.of(context).primary,
                                      size: 28.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              description.isNotEmpty
                                  ? description
                                  : 'No description',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                            subtitle: Text(
                              userName,
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                            onTap: () {
                              context.pushNamed(
                                SingleVideoWidget.routeName,
                                queryParameters: {
                                  'videoRef': serializeParam(
                                    docs[i].reference,
                                    ParamType.DocumentReference,
                                  ),
                                }.withoutNulls,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryInfo {
  final String label;
  final IconData icon;

  const _CategoryInfo(this.label, this.icon);
}

Widget _suggestedUsersSection(BuildContext context) {
  final myRef = currentUserReference;
  if (myRef == null) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Creators',
          style: FlutterFlowTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 120.0,
          child: StreamBuilder<List<UsersRecord>>(
            stream: queryUsersRecord(
              queryBuilder: (q) =>
                  q.orderBy('total_likes', descending: true).limit(10),
            ),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final users = snap.data!
                  .where((u) => u.uid != currentUserUid)
                  .take(6)
                  .toList();
              if (users.isEmpty) {
                return const SizedBox.shrink();
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, i) {
                  final u = users[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: InkWell(
                      onTap: () {
                        context.pushNamed(
                          ProfileOtherWidget.routeName,
                          queryParameters: {
                            'userID': serializeParam(
                              u.reference,
                              ParamType.DocumentReference,
                            ),
                          }.withoutNulls,
                        );
                      },
                      child: Container(
                        width: 80.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24.0,
                              backgroundImage:
                                  u.photoUrl.isNotEmpty
                                      ? NetworkImage(u.photoUrl)
                                      : null,
                              backgroundColor:
                                  FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.1),
                              child: u.photoUrl.isEmpty
                                  ? Text(
                                      (u.displayName.isNotEmpty
                                              ? u.displayName[0]
                                              : '?')
                                          .toUpperCase(),
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              u.displayName.isNotEmpty
                                  ? u.displayName
                                  : u.username,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.poppins(),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
