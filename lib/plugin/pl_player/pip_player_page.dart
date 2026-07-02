import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pip_flutter/pipflutter_player.dart';
import 'package:pip_flutter/pipflutter_player_configuration.dart';
import 'package:pip_flutter/pipflutter_player_controller.dart';
import 'package:pip_flutter/pipflutter_player_data_source.dart';

class PipPlayerPage extends StatefulWidget {
  const PipPlayerPage({
    required this.videoUrl,
    this.isLive = false,
    this.aspectRatio,
    this.startAt,
    this.isPlaying = true,
    this.onClosed,
    super.key,
  });

  final String videoUrl;
  final bool isLive;
  final double? aspectRatio;
  final Duration? startAt;
  final bool isPlaying;
  final VoidCallback? onClosed;

  @override
  State<PipPlayerPage> createState() => _PipPlayerPageState();
}

class _PipPlayerPageState extends State<PipPlayerPage> {
  late final PipFlutterPlayerController _controller;
  final GlobalKey _playerKey = GlobalKey();
  bool _isEnteringPip = true;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _controller = PipFlutterPlayerController(
      PipFlutterPlayerConfiguration(
        autoPlay: widget.isPlaying,
        startAt: widget.startAt,
        aspectRatio: widget.aspectRatio,
        fit: BoxFit.contain,
        allowedScreenSleep: false,
        handleLifecycle: true,
      ),
    );
    _controller.setPipFlutterPlayerGlobalKey(_playerKey);
    _controller.setupDataSource(
      widget.videoUrl.startsWith('http') || widget.videoUrl.startsWith('https')
          ? PipFlutterPlayerDataSource.network(
              widget.videoUrl,
              liveStream: widget.isLive,
            )
          : PipFlutterPlayerDataSource.file(widget.videoUrl),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final supported = await _controller.isPictureInPictureSupported();
        if (!mounted) return;
        if (supported) {
          await _controller.enablePictureInPicture(_playerKey);
          if (mounted) {
            setState(() => _isEnteringPip = false);
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isEnteringPip = false);
        }
      }
    });

    _fallbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isEnteringPip) {
        setState(() => _isEnteringPip = false);
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    widget.onClosed?.call();
    unawaited(_controller.disablePictureInPicture());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isEnteringPip) ...[
                Text(
                  Platform.isIOS ? '正在进入画中画…' : '正在进入小窗…',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const CircularProgressIndicator.adaptive(),
              ],
              const SizedBox(height: 1),
              SizedBox(
                width: 1,
                height: 1,
                child: PipFlutterPlayer(
                  controller: _controller,
                  key: _playerKey,
                ),
              ),
              const SizedBox(height: 1),
              TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('退出', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
