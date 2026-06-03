import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'schedule_stream_model.dart';
export 'schedule_stream_model.dart';

class ScheduleStreamWidget extends StatefulWidget {
  const ScheduleStreamWidget({super.key});

  static String routeName = 'ScheduleStream';
  static String routePath = 'schedule-stream';

  @override
  State<ScheduleStreamWidget> createState() => _ScheduleStreamWidgetState();
}

class _ScheduleStreamWidgetState extends State<ScheduleStreamWidget> {
  late ScheduleStreamModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  int? _durationMinutes;
  bool _isExclusive = false;
  bool _saving = false;

  final List<int> _durationOptions = [15, 30, 45, 60, 90, 120, 180];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ScheduleStreamModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select stream date',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      helpText: 'Select stream time',
    );
    if (time == null || !mounted) return;
    safeSetState(() {
      _scheduledDate = date;
      _scheduledTime = time;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_scheduledDate == null || _scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }
    final userRef = currentUserReference;
    if (userRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      _scheduledTime!.hour,
      _scheduledTime!.minute,
    );

    safeSetState(() => _saving = true);
    try {
      final data = createScheduledStreamsRecordData(
        creator: userRef,
        title: title,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        scheduledTime: scheduledDateTime,
        durationMinutes: _durationMinutes,
        isExclusive: _isExclusive,
        createdTime: getCurrentTimestamp,
        isCancelled: false,
        notificationSent: false,
      );
      await ScheduledStreamsRecord.collection.add(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stream scheduled successfully!')),
        );
        context.safePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) safeSetState(() => _saving = false);
    }
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return 'Not set';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
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
            'Schedule Stream',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(),
                  letterSpacing: 0.0,
                ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter stream title',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  hintStyle: FlutterFlowTheme.of(context).bodySmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Tell viewers what to expect',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  hintStyle: FlutterFlowTheme.of(context).bodySmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          _scheduledDate != null && _scheduledTime != null
                              ? '${_scheduledDate!.month}/${_scheduledDate!.day}/${_scheduledDate!.year} '
                                  '${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                              : 'Select date & time *',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                initialValue: _durationMinutes,
                decoration: InputDecoration(
                  labelText: 'Duration (optional)',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                hint: Text(
                  'Select duration',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                items: _durationOptions.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(_formatDuration(d)),
                  );
                }).toList(),
                onChanged: (v) => safeSetState(() => _durationMinutes = v),
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exclusive Stream',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        Text(
                          'Only subscribers can watch',
                          style: FlutterFlowTheme.of(context).bodySmall,
                        ),
                      ],
                    ),
                    Switch(
                      value: _isExclusive,
                      onChanged: (v) => safeSetState(() => _isExclusive = v),
                      activeThumbColor: FlutterFlowTheme.of(context).primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: FlutterFlowTheme.of(context).primaryBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Schedule Stream',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(),
                              letterSpacing: 0.0,
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
