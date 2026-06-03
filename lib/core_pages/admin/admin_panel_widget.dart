import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_panel_model.dart';
export 'admin_panel_model.dart';

class AdminPanelWidget extends StatefulWidget {
  const AdminPanelWidget({super.key});

  static String routeName = 'AdminPanel';
  static String routePath = 'admin-panel';

  @override
  State<AdminPanelWidget> createState() => _AdminPanelWidgetState();
}

class _AdminPanelWidgetState extends State<AdminPanelWidget>
    with TickerProviderStateMixin {
  late AdminPanelModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminPanelModel());
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
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
          title: Text(
            'Admin Panel',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: FlutterFlowTheme.of(context).primary,
            unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
            indicatorColor: FlutterFlowTheme.of(context).primary,
            tabs: const [
              Tab(text: 'Reports'),
              Tab(text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _reportsTab(context),
            _usersTab(context),
          ],
        ),
      ),
    );
  }

  Widget _reportsTab(BuildContext context) {
    return StreamBuilder<List<ReportsRecord>>(
      stream: queryReportsRecord(
        queryBuilder: (q) => q
            .where('status', isEqualTo: 'pending')
            .orderBy('created_time', descending: true)
            .limit(50),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading reports: ${snapshot.error}',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          );
        }
        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64.0,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'No pending reports',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.poppins(),
                      ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _reportCard(context, report);
          },
        );
      },
    );
  }

  Widget _reportCard(BuildContext context, ReportsRecord report) {
    return FutureBuilder<UsersRecord?>(
      future: report.reportedUser?.get().then((s) => UsersRecord.fromSnapshot(s)),
      builder: (context, reportedSnapshot) {
        final reportedUser = reportedSnapshot.data;
        return FutureBuilder<UsersRecord?>(
          future: report.reportedBy?.get().then((s) => UsersRecord.fromSnapshot(s)),
          builder: (context, reporterSnapshot) {
            final reporter = reporterSnapshot.data;
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              color: FlutterFlowTheme.of(context).secondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .error
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Icon(
                            Icons.warning_amber,
                            color: FlutterFlowTheme.of(context).error,
                            size: 20.0,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report #${report.reference.id.substring(0, 8)}',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600),
                                    ),
                              ),
                              Text(
                                'Reason: ${report.reason}',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      font: GoogleFonts.poppins(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (report.hasDetails() && report.details!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          report.details!,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.poppins(),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                              ),
                        ),
                      ),
                    if (reportedUser != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16.0,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Reported: @${reportedUser.username}',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.poppins(),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    if (reporter != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag,
                              size: 16.0,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'By: @${reporter.username}',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.poppins(),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _dismissReport(report),
                          icon: const Icon(Icons.close, size: 16.0),
                          label: const Text('Dismiss'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                FlutterFlowTheme.of(context).secondaryText,
                            side: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText
                                  .withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton.icon(
                          onPressed: () => _warnUser(report, reportedUser),
                          icon: const Icon(Icons.warning, size: 16.0),
                          label: const Text('Warn User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                FlutterFlowTheme.of(context).error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _dismissReport(ReportsRecord report) async {
    try {
      await report.reference.update({'status': 'dismissed'});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report dismissed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _warnUser(
      ReportsRecord report, UsersRecord? reportedUser) async {
    if (reportedUser == null) return;
    final reason = report.reason;
    final details = report.hasDetails() ? report.details : '';

    try {
      await FirebaseFirestore.instance
          .collection('user_warnings')
          .add({
        'user': reportedUser.reference,
        'reason': reason ?? 'Unspecified',
        'details': details ?? '',
        'issued_by': currentUserReference,
        'created_time': FieldValue.serverTimestamp(),
      });

      await report.reference.update({'status': 'actioned'});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Warning issued to @${reportedUser.username}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _usersTab(BuildContext context) {
    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(
        queryBuilder: (q) =>
            q.orderBy('created_time', descending: true).limit(100),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading users: ${snapshot.error}'),
          );
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _userCard(context, user);
          },
        );
      },
    );
  }

  Widget _userCard(BuildContext context, UsersRecord user) {
    final isAdmin = user.role == 'admin';
    final isBanned = user.suspended;
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : null,
          backgroundColor:
              FlutterFlowTheme.of(context).primary.withOpacity(0.1),
          child: user.photoUrl.isEmpty
              ? Text(
                  (user.username.isNotEmpty
                          ? user.username[0]
                          : user.email[0])
                      .toUpperCase(),
                  style: FlutterFlowTheme.of(context).titleSmall,
                )
              : null,
        ),
        title: Text(
          user.username.isNotEmpty ? '@${user.username}' : user.email,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
        ),
        subtitle: Text(
          '${user.email}  •  ${user.totalLikes} likes',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.poppins(),
              ),
        ),
        trailing: isBanned
            ? Chip(
                label: Text(
                  'Banned',
                  style: GoogleFonts.poppins(
                    fontSize: 11.0,
                    color: Colors.white,
                  ),
                ),
                backgroundColor:
                    FlutterFlowTheme.of(context).error,
              )
            : isAdmin
                ? Chip(
                    label: Text(
                      'Admin',
                      style: GoogleFonts.poppins(
                        fontSize: 11.0,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor:
                        FlutterFlowTheme.of(context).primary,
                  )
                : null,
        onTap: () {
          _showUserActions(context, user);
        },
      ),
    );
  }

  Future<void> _banUser(UsersRecord user, {String? reason}) async {
    try {
      await user.reference.update({
        'suspended': true,
        'suspension_reason': reason ?? 'Violation of terms of service',
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error banning user: $e')),
        );
      }
    }
  }

  Future<void> _unbanUser(UsersRecord user) async {
    try {
      await user.reference.update({
        'suspended': false,
        'suspension_reason': FieldValue.delete(),
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error unbanning user: $e')),
        );
      }
    }
  }

  void _showUserActions(BuildContext context, UsersRecord user) {
    final isAdmin = user.role == 'admin';
    final isBanned = user.suspended;
    showModalBottomSheet(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actions for @${user.username}',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600),
                      ),
                ),
                const SizedBox(height: 16.0),
                if (!isAdmin)
                  ListTile(
                    leading: Icon(Icons.admin_panel_settings,
                        color: FlutterFlowTheme.of(context).primary),
                    title: const Text('Make Admin'),
                    onTap: () async {
                      try {
                        await user.reference
                            .update({'role': 'admin'});
                        Navigator.pop(sheetContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '@${user.username} is now an admin')),
                          );
                        }
                      } catch (e) {
                        Navigator.pop(sheetContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  )
                else
                  ListTile(
                    leading: Icon(Icons.person,
                        color: FlutterFlowTheme.of(context)
                            .secondaryText),
                    title: const Text('Remove Admin'),
                    onTap: () async {
                      try {
                        await user.reference
                            .update({'role': FieldValue.delete()});
                        Navigator.pop(sheetContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '@${user.username} admin access removed')),
                          );
                        }
                      } catch (e) {
                        Navigator.pop(sheetContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  ),
                if (isBanned)
                  ListTile(
                    leading: Icon(Icons.restore,
                        color: FlutterFlowTheme.of(context).primary),
                    title: const Text('Unban User'),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await _unbanUser(user);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '@${user.username} has been unbanned')),
                        );
                      }
                    },
                  )
                else
                  ListTile(
                    leading: Icon(Icons.block,
                        color: FlutterFlowTheme.of(context).error),
                    title: const Text('Ban User'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _banDialog(context, user);
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.warning_amber,
                      color: FlutterFlowTheme.of(context).error),
                  title: const Text('Send Warning'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _sendWarningDialog(context, user);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _banDialog(
      BuildContext context, UsersRecord user) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              FlutterFlowTheme.of(context).secondaryBackground,
          title: Text(
            'Ban @${user.username}',
            style: FlutterFlowTheme.of(context).titleSmall,
          ),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: 'Ban reason...',
              hintStyle: FlutterFlowTheme.of(context).bodySmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Ban User'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _banUser(user, reason: reasonController.text.isNotEmpty
          ? reasonController.text
          : null);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('@${user.username} has been banned')),
        );
      }
    }
    reasonController.dispose();
  }

  Future<void> _sendWarningDialog(
      BuildContext context, UsersRecord user) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              FlutterFlowTheme.of(context).secondaryBackground,
          title: Text(
            'Warn @${user.username}',
            style: FlutterFlowTheme.of(context).titleSmall,
          ),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: 'Warning reason...',
              hintStyle: FlutterFlowTheme.of(context).bodySmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Send Warning'),
            ),
          ],
        );
      },
    );

    if (result == true && reasonController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('user_warnings')
            .add({
          'user': user.reference,
          'reason': reasonController.text,
          'details': '',
          'issued_by': currentUserReference,
          'created_time': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Warning sent to @${user.username}')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
    reasonController.dispose();
  }
}
