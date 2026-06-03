import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upcoming_streams_model.dart';
export 'upcoming_streams_model.dart';

class UpcomingStreamsWidget extends StatefulWidget {
  const UpcomingStreamsWidget({super.key});

  static String routeName = 'UpcomingStreams';
  static String routePath = 'upcoming-streams';

  @override
  State<UpcomingStreamsWidget> createState() => _UpcomingStreamsWidgetState();
}

class _UpcomingStreamsWidgetState extends State<UpcomingStreamsWidget> {
  late UpcomingStreamsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UpcomingStreamsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$min $amPm';
  }

  Future<void> _notifyMe(DocumentReference streamRef) async {
    final userRef = currentUserReference;
    if (userRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to get notified')),
      );
      return;
    }
    try {
      await streamRef.collection('reminders').doc(userRef.id).set({
        'user': userRef,
        'created_at': getCurrentTimestamp,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You\'ll be notified!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
            'Upcoming Streams',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(),
                  letterSpacing: 0.0,
                ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: ScheduledStreamsRecord.collection
              .where('is_cancelled', isEqualTo: false)
              .where('scheduled_time', isGreaterThan: getCurrentTimestamp)
              .orderBy('scheduled_time', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Could not load upcoming streams.',
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
                    'No upcoming streams.\nCheck back later for scheduled live streams.',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 24.0),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final raw = docs[i].data();
                final data =
                    raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                final creatorRef =
                    data['creator'] as DocumentReference?;
                final title = (data['title'] ?? '').toString();
                final description = (data['description'] ?? '').toString();
                final scheduledTime =
                    data['scheduled_time'] as DateTime?;
                final duration =
                    (data['duration_minutes'] as num?)?.toInt();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<UsersRecord>(
                          stream: creatorRef != null
                              ? UsersRecord.getDocument(creatorRef)
                              : null,
                          builder: (context, u) {
                            final name =
                                u.data?.displayName.isNotEmpty == true
                                    ? u.data!.displayName
                                    : 'Creator';
                            return Row(
                              children: [
                                Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: FlutterFlowTheme.of(context)
                                        .primary,
                                  ),
                                  child: Center(
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.poppins(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  name,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          title,
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.poppins(),
                                letterSpacing: 0.0,
                              ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            description,
                            style: FlutterFlowTheme.of(context).bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              scheduledTime != null
                                  ? _formatDateTime(scheduledTime)
                                  : 'TBD',
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                            if (duration != null && duration > 0) ...[
                              const SizedBox(width: 16.0),
                              Icon(
                                Icons.timer_outlined,
                                size: 16.0,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                _formatDuration(duration),
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _notifyMe(docs[i].reference),
                            icon: const Icon(Icons.notifications_outlined,
                                size: 18.0),
                            label: const Text('Notify Me'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  FlutterFlowTheme.of(context).primary,
                              foregroundColor:
                                  FlutterFlowTheme.of(context).primaryBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
