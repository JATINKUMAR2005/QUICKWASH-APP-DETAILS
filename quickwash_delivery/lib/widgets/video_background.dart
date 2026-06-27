import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  final Widget child;
  final String videoUrl;
  final double overlayOpacity;

  const VideoBackground({
    super.key,
    required this.child,
    this.videoUrl = 'https://assets.mixkit.co/videos/preview/mixkit-bubbles-of-water-under-a-blue-light-43015-large.mp4',
    this.overlayOpacity = 0.65,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.setLooping(true);
        _controller!.setVolume(0.0); // Ensure muted
        _controller!.play();
      }
    } catch (e) {
      debugPrint('VideoBackground initialization failed: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Standard glassmorphic gradient background as base & fallback
    final Widget backgroundGradient = Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [Color(0xFF0A1535), Color(0xFF0A0F1E)],
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Base Gradient
          Positioned.fill(child: backgroundGradient),

          // 2. Video Layer (if initialized and no error)
          if (_isInitialized && _controller != null && !_hasError)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),

          // 3. Legibility & Ambient Glass Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F1E).withValues(alpha: widget.overlayOpacity),
              ),
            ),
          ),

          // 4. Foreground Content
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}
