import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityFeedWidget extends StatefulWidget {
  const ActivityFeedWidget({super.key});

  static String routeName = 'ActivityFeed';
  static String routePath = 'activity';

  @override
  State<ActivityFeedWidget> createState() => _ActivityFeedWidgetState();
}

class _ActivityFeedWidgetState extends State<ActivityFeedWidget> {
  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity')),
        body: const Center(child: Text('Sign in to see activity.')),
      );
    }

    final following = currentUserDocument?.following ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activity',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: following.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Follow some creators to see their activity here.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.poppins(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
              ),
            )
          : StreamBuilder<List<ActivitiesRecord>>(
              stream: queryActivitiesRecord(
                queryBuilder: (q) => q
                    .where('actor', whereIn: following.take(10).toList())
                    .orderBy('created_time', descending: true)
                    .limit(50),
                // Note: Firestore whereIn limited to 10 values; for
                // production use a more scalable approach.
              ),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text('Error: ${snap.error}'),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final activities = snap.data!;
                if (activities.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No recent activity from creators you follow.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              font: GoogleFonts.poppins(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: activities.length,
                  itemBuilder: (context, i) =>
                      _activityTile(context, activities[i]),
                );
              },
            ),
    );
  }

  Widget _activityTile(BuildContext context, ActivitiesRecord activity) {
    final type = activity.type;
    IconData icon;
    Color iconColor;
    String actionText;

    switch (type) {
      case 'like':
        icon = Icons.favorite;
        iconColor = Colors.red;
        actionText = 'liked a video';
        break;
      case 'comment':
        icon = Icons.chat_bubble;
        iconColor = Colors.blue;
        actionText = 'commented on a video';
        break;
      case 'follow':
        icon = Icons.person_add;
        iconColor = Colors.green;
        actionText = 'followed someone';
        break;
      case 'subscribe':
        icon = Icons.star;
        iconColor = Colors.amber;
        actionText = 'subscribed to someone';
        break;
      case 'tip':
        icon = Icons.monetization_on;
        iconColor = Colors.green;
        actionText = 'sent a tip';
        break;
      default:
        icon = Icons.circle;
        iconColor = Colors.grey;
        actionText = type ?? 'did something';
    }

    return FutureBuilder<UsersRecord?>(
      future: activity.actor?.get().then((s) => UsersRecord.fromSnapshot(s)),
      builder: (context, actorSnap) {
        final actor = actorSnap.data;
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: actor?.photoUrl.isNotEmpty == true
                  ? NetworkImage(actor!.photoUrl)
                  : null,
              backgroundColor:
                  FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              child: actor?.photoUrl.isNotEmpty == true
                  ? null
                  : Text(
                      ((actor?.username.isNotEmpty == true
                                  ? actor!.username
                                  : '?')[0])
                          .toUpperCase(),
                    ),
            ),
            title: Text(
              actor?.displayName.isNotEmpty == true
                  ? actor!.displayName
                  : 'Someone',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
            ),
            subtitle: Text(
              actionText,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
            trailing: Icon(icon, color: iconColor, size: 20.0),
            onTap: () {
              if (activity.type == 'follow' && activity.targetUser != null) {
                context.pushNamed(
                  ProfileOtherWidget.routeName,
                  queryParameters: {
                    'userID': serializeParam(
                      activity.targetUser,
                      ParamType.DocumentReference,
                    ),
                  }.withoutNulls,
                );
              } else if (activity.type == 'like' ||
                  activity.type == 'comment') {
                if (activity.targetVideo != null) {
                  context.pushNamed(
                    SingleVideoWidget.routeName,
                    queryParameters: {
                      'videoRef': serializeParam(
                        activity.targetVideo,
                        ParamType.DocumentReference,
                      ),
                    }.withoutNulls,
                  );
                }
              } else if (activity.actor != null) {
                context.pushNamed(
                  ProfileOtherWidget.routeName,
                  queryParameters: {
                    'userID': serializeParam(
                      activity.actor,
                      ParamType.DocumentReference,
                    ),
                  }.withoutNulls,
                );
              }
            },
          ),
        );
      },
    );
  }
}
