import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPreferencesWidget extends StatefulWidget {
  const NotificationPreferencesWidget({super.key});

  static String routeName = 'NotificationPreferences';
  static String routePath = 'notifications';

  @override
  State<NotificationPreferencesWidget> createState() =>
      _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState
    extends State<NotificationPreferencesWidget> {
  bool _pushEnabled = true;
  bool _likes = true;
  bool _comments = true;
  bool _followers = true;
  bool _liveStarted = true;
  bool _directMessages = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userRef = currentUserReference;
    if (userRef == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userRef.id)
        .collection('notification_settings')
        .doc('preferences')
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _pushEnabled = data['push_enabled'] as bool? ?? true;
        _likes = data['likes'] as bool? ?? true;
        _comments = data['comments'] as bool? ?? true;
        _followers = data['followers'] as bool? ?? true;
        _liveStarted = data['live_started'] as bool? ?? true;
        _directMessages = data['direct_messages'] as bool? ?? true;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveSetting(String field, bool value) async {
    final userRef = currentUserReference;
    if (userRef == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userRef.id)
        .collection('notification_settings')
        .doc('preferences')
        .set({
      field: value,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Preferences',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.poppins(),
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildToggle(
                  context,
                  title: 'Push Notifications',
                  subtitle: 'Master toggle for all push notifications',
                  value: _pushEnabled,
                  onChanged: (v) {
                    setState(() => _pushEnabled = v);
                    _saveSetting('push_enabled', v);
                  },
                ),
                _buildToggle(
                  context,
                  title: 'Likes',
                  subtitle: 'When someone likes your content',
                  value: _likes,
                  onChanged: (v) {
                    setState(() => _likes = v);
                    _saveSetting('likes', v);
                  },
                ),
                _buildToggle(
                  context,
                  title: 'Comments',
                  subtitle: 'When someone comments on your content',
                  value: _comments,
                  onChanged: (v) {
                    setState(() => _comments = v);
                    _saveSetting('comments', v);
                  },
                ),
                _buildToggle(
                  context,
                  title: 'New Followers',
                  subtitle: 'When someone follows you',
                  value: _followers,
                  onChanged: (v) {
                    setState(() => _followers = v);
                    _saveSetting('followers', v);
                  },
                ),
                _buildToggle(
                  context,
                  title: 'Live Stream Started',
                  subtitle: 'When a favorite creator goes live',
                  value: _liveStarted,
                  onChanged: (v) {
                    setState(() => _liveStarted = v);
                    _saveSetting('live_started', v);
                  },
                ),
                _buildToggle(
                  context,
                  title: 'Direct Messages',
                  subtitle: 'When you receive a direct message',
                  value: _directMessages,
                  onChanged: (v) {
                    setState(() => _directMessages = v);
                    _saveSetting('direct_messages', v);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: FlutterFlowTheme.of(context).bodySmall,
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: FlutterFlowTheme.of(context).primary,
    );
  }
}
