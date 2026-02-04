import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../contants/dio_client.dart';
import '../contants/end_point.dart';
import '../repository/repository.dart';
import 'home_page.dart';

/// AI Planner screen: natural language input → generate & optionally auto-schedule tasks.
/// Used as a tab in [HomePage] with [AppBottomNavBar].
class AiPlanScreen extends StatefulWidget {
  /// Tab index for AI Planner in [HomePage] bottom nav.
  static const int tabIndex = 2;

  final Function(int)? onTabChanged;

  const AiPlanScreen({super.key, this.onTabChanged});

  @override
  State<AiPlanScreen> createState() => _AiPlanScreenState();
}

class _AiPlanScreenState extends State<AiPlanScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// Auto-schedule tasks after generation.
  bool _autoScheduleAfterGenerating = false;

  static const Color _screenBg = Color(0xFFF5F5F5);
  static const Color _cardBg = Colors.white;
  static const Color _primaryBlue = Color(0xFF3A00FF);
  static const Color _micIconBlue = Color(0xFF5C6BC0);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textHint = Color(0xFF6B6B80);
  static const Color _toggleTrackInactive = Color(0xFFE0E0E0);

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Thời gian hiện tại theo local, định dạng ISO 8601 có timezone (vd: 2026-01-05T22:00:00+07:00).
  static String _nowIso8601Local() {
    final now = DateTime.now();
    final o = now.timeZoneOffset;
    final sign = o.isNegative ? '-' : '+';
    final h = o.inHours.abs().toString().padLeft(2, '0');
    final m = o.inMinutes.remainder(60).abs().toString().padLeft(2, '0');
    final tz = '$sign$h:$m';
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'
        'T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}$tz';
  }

  Future<void> _onGenerateTasks() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    try {
      await Api.instance.restClient.plannerParse({
        'inputText': text,
        'now': _nowIso8601Local(),
      });
      // TODO: xử lý kết quả (vd: refresh danh sách task, điều hướng, hoặc hiển thị thông báo)
    } catch (e) {
      // TODO: hiển thị lỗi (Snackbar / EasyLoading)
    }
  }

  Future<void> _onMicTap() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _VoiceRecordDialog(
        onTranscribed: (String text) {
          if (text.isNotEmpty) {
            final current = _inputController.text;
            _inputController.text = current.isEmpty ? text : '$current\n$text';
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputCard(),
                    SizedBox(height: 20.h),
                    _buildGenerateButton(),
                    SizedBox(height: 20.h),
                    _buildAutoScheduleToggle(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.onTabChanged != null
          ? AppBottomNavBar(
              currentIndex: AiPlanScreen.tabIndex,
              onTabChanged: widget.onTabChanged!,
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, left: 20.w, right: 20.w),
      child: Center(
        child: Text(
          'AI Planner',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    const String placeholder = '''E.g.,
- Gym for 1 hour tonight at 8 PM, remind me 15 minutes before
- Team meeting tomorrow at 9 AM, prepare slides
- Dedicate 30 minutes daily to learning English for the next 7 days...''';

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: BoxConstraints(minHeight: 220.h),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 56.h),
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              maxLines: null,
              minLines: 8,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: 15.sp,
                color: _textDark,
                height: 1.45,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  color: _textHint,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12.w, bottom: 12.h),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _micIconBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: _onMicTap,
                borderRadius: BorderRadius.circular(24.r),
                child: Icon(
                  Icons.mic_rounded,
                  color: _micIconBlue,
                  size: 26.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Material(
      color: _primaryBlue,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: _onGenerateTasks,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          alignment: Alignment.center,
          child: Text(
            'Generate tasks',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoScheduleToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Auto-schedule after generating',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: _textDark,
          ),
        ),
        Switch(
          value: _autoScheduleAfterGenerating,
          onChanged: (value) {
            setState(() => _autoScheduleAfterGenerating = value);
          },
          activeColor: _primaryBlue,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: _toggleTrackInactive,
        ),
      ],
    );
  }
}

// --- Voice record popup (Listening → Transcribing) ---

enum _VoiceDialogState { listening, transcribing }

class _VoiceRecordDialog extends StatefulWidget {
  final void Function(String text) onTranscribed;

  const _VoiceRecordDialog({required this.onTranscribed});

  @override
  State<_VoiceRecordDialog> createState() => _VoiceRecordDialogState();
}

class _VoiceRecordDialogState extends State<_VoiceRecordDialog> with SingleTickerProviderStateMixin {
  _VoiceDialogState _state = _VoiceDialogState.listening;
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _maxDurationTimer;
  late AnimationController _pulseController;

  static const Color _primaryBlue = Color(0xFF3A00FF);
  static const Color _redMic = Color(0xFFE53935);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textHint = Color(0xFF6B6B80);
  static const Color _btnGrey = Color(0xFFE0E0E0);
  static const Duration _maxRecordingDuration = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _startRecording();
  }

  /// Ghi âm mặc định: [RecordConfig] dùng encoder AAC-LC → file **M4A** (.m4a).
  Future<void> _startRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: filePath);
      _maxDurationTimer = Timer(_maxRecordingDuration, () => _stopRecording());
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
  }

  Future<void> _stopRecording() async {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    try {
      final path = await _recorder.stop();
      if (path != null && mounted) {
        setState(() => _state = _VoiceDialogState.transcribing);
        await _uploadAndTranscribe(path);
      } else if (mounted) {
        print('===============path is null');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  /// API nhận file âm thanh raw với các định dạng: MP3, WAV, AAC, FLAC, OGG/OPUS, M4A, MP4.
  static const Set<String> _supportedAudioExtensions = {
    'mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'mp4',
  };

  /// MIME type cho từng định dạng (tránh lỗi "Unsupported MIME type: application/octet-stream" từ Gemini).
  static MediaType _audioMediaType(String ext) {
    switch (ext) {
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'aac':
        return MediaType('audio', 'aac');
      case 'flac':
        return MediaType('audio', 'flac');
      case 'ogg':
        return MediaType('audio', 'ogg');
      case 'm4a':
      case 'mp4':
        return MediaType('audio', 'mp4');
      default:
        return MediaType('audio', 'mp4');
    }
  }

  Future<void> _uploadAndTranscribe(String path) async {
    try {
      final rawExt = path.contains('.') ? path.split('.').last.toLowerCase() : 'm4a';
      final ext = _supportedAudioExtensions.contains(rawExt) ? rawExt : 'm4a';
      final uploadFilename = 'audio.$ext';
      final dio = dioClient(Endpoints.baseUrl);
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          path,
          filename: uploadFilename,
          contentType: _audioMediaType(ext),
        ),
      });
      final apiPath = Endpoints.voiceTranscribeGemini.startsWith('/')
          ? Endpoints.voiceTranscribeGemini.replaceFirst('/', '')
          : Endpoints.voiceTranscribeGemini;
      final response = await dio.post(apiPath, data: formData);
      if (!mounted) return;
      final data = response.data;
      String? text;
      if (data is Map) {
        text = (data['text'] ?? data['transcript'] ?? data['result'])?.toString();
      }
      widget.onTranscribed(text ?? '');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _cancel() {
    _maxDurationTimer?.cancel();
    _recorder.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _maxDurationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Fixed content height so popup doesn't change size (avoids jitter during animation).
  static double get _contentHeight => 180.h;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 340.w),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _contentHeight,
                child: _state == _VoiceDialogState.listening
                    ? _buildListeningContent()
                    : _buildTranscribingContent(),
              ),
              SizedBox(height: 24.h),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListeningContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120.w,
          height: 120.w,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  ...List.generate(3, (i) {
                    final t = (_pulseController.value + i * 0.33) % 1.0;
                    final scale = 1.0 + t * 0.5;
                    final opacity = 1.0 - t;
                    return Center(
                      child: IgnorePointer(
                        child: Container(
                          width: 64.w * scale,
                          height: 64.w * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _redMic.withValues(alpha: opacity * 0.6), width: 2),
                          ),
                        ),
                      ),
                    );
                  }),
                  Icon(Icons.mic, size: 48.sp, color: _redMic),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Listening...',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _textDark),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'Say the task you want to create.',
            style: TextStyle(fontSize: 14.sp, color: _textHint),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscribingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 48.w,
          height: 48.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Transcribing...',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _textDark),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'Converting your voice to text. This may take a few seconds.',
            style: TextStyle(fontSize: 14.sp, color: _textHint),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _cancel,
            style: TextButton.styleFrom(
              backgroundColor: _btnGrey,
              foregroundColor: _textDark,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Cancel', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
          ),
        ),
        if (_state == _VoiceDialogState.listening) ...[
          SizedBox(width: 12.w),
          Expanded(
            child: TextButton(
              onPressed: _stopRecording,
              style: TextButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('Stop', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ],
    );
  }
}
