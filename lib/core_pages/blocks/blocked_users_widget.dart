import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blocked_users_model.dart';
export 'blocked_users_model.dart';

class BlockedUsersWidget extends StatefulWidget {
  const BlockedUsersWidget({super.key});

  static String routeName = 'BlockedUsers';
  static String routePath = 'blocked-users';

  @override
  State<BlockedUsersWidget> createState() => _BlockedUsersWidgetState();
}

class _BlockedUsersWidgetState extends State<BlockedUsersWidget> {
  late BlockedUsersModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BlockedUsersModel());

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
          title: Text(
            'Blocked Users',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: currentUserReference == null
            ? const SizedBox.shrink()
            : StreamBuilder<List<BlocksRecord>>(
                stream: queryBlocksRecord(
                  queryBuilder: (q) => q
                      .where('blocked_by', isEqualTo: currentUserReference)
                      .orderBy('created_time', descending: true)
                      .limit(50),
                ),
                builder: (context, snapshot) {
                  final blocks = snapshot.data ?? [];
                  if (blocks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 64.0,
                            color:
                                FlutterFlowTheme.of(context).secondaryText,
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'No blocked users',
                            style:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      font: GoogleFonts.poppins(),
                                    ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      return FutureBuilder<UsersRecord?>(
                        future: block.blockedUser?.get().then(
                            (s) => UsersRecord.fromSnapshot(s)),
                        builder: (context, userSnapshot) {
                          final user = userSnapshot.data;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    (user?.photoUrl.isNotEmpty ?? false)
                                        ? NetworkImage(user!.photoUrl)
                                        : null,
                                backgroundColor:
                                    FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.1),
                                child: (user?.photoUrl.isNotEmpty ?? false)
                                    ? null
                                    : Text(
                                        ((user?.username.isNotEmpty ??
                                                    false)
                                                ? user!.username[0]
                                                : '?')
                                            .toUpperCase(),
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall,
                                      ),
                              ),
                              title: Text(
                                user?.username.isNotEmpty == true
                                    ? '@${user!.username}'
                                    : 'Unknown user',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600),
                                    ),
                              ),
                              trailing: TextButton(
                                onPressed: () =>
                                    _unblockUser(block),
                                child: Text(
                                  'Unblock',
                                  style: GoogleFonts.poppins(
                                    color:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                ),
                              ),
                            ),
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

  Future<void> _unblockUser(BlocksRecord block) async {
    await block.reference.delete();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked')),
      );
    }
  }
}
