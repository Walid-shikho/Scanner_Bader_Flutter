import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/bader_adaptive_scaffold.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late final SplashController controller;
  late final VideoPlayerController _videoController;
  Timer? _initializationGuard;
  Timer? _playbackGuard;
  String? _destination;
  bool _initialized = false;
  bool _presentationFinished = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SplashController>();
    _videoController = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..addListener(_handlePlaybackState);
    _prepareDestination();
    _initializationGuard = Timer(
      const Duration(seconds: 10),
      _finishPresentation,
    );
    _initializeVideo();
  }

  Future<void> _prepareDestination() async {
    final destination = await controller.resolveDestination();
    if (!mounted) return;
    _destination = destination;
    _tryNavigate();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      if (!mounted || _presentationFinished) return;
      _initializationGuard?.cancel();
      await _videoController.setLooping(false);
      await _videoController.setVolume(0);
      if (!mounted || _presentationFinished) return;
      setState(() => _initialized = true);
      await _videoController.play();
      final duration = _videoController.value.duration;
      _playbackGuard = Timer(
        duration > Duration.zero
            ? duration + const Duration(seconds: 2)
            : const Duration(seconds: 10),
        _finishPresentation,
      );
    } catch (_) {
      _finishPresentation();
    }
  }

  void _handlePlaybackState() {
    if (_presentationFinished || !_videoController.value.isInitialized) return;
    final value = _videoController.value;
    if (value.hasError) {
      _finishPresentation();
      return;
    }
    if (value.duration <= Duration.zero) return;
    final remaining = value.duration - value.position;
    if (!value.isPlaying && remaining <= const Duration(milliseconds: 160)) {
      _finishPresentation();
    }
  }

  void _finishPresentation() {
    if (_presentationFinished) return;
    _presentationFinished = true;
    _initializationGuard?.cancel();
    _playbackGuard?.cancel();
    _tryNavigate();
  }

  void _tryNavigate() {
    if (!mounted || _navigated || !_presentationFinished || _destination == null) {
      return;
    }
    _navigated = true;
    Get.offAllNamed<void>(_destination!);
  }

  @override
  Widget build(BuildContext context) {
    return BaderAdaptiveScaffold(
      usePageBackground: false,
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SplashFallback(),
          if (_initialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _initializationGuard?.cancel();
    _playbackGuard?.cancel();
    _videoController
      ..removeListener(_handlePlaybackState)
      ..dispose();
    super.dispose();
  }
}

class _SplashFallback extends StatelessWidget {
  const _SplashFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Image.asset(
            'assets/images/bader_logo.png',
            width: 150,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
