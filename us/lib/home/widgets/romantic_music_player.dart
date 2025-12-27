import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RomanticMusicPlayer extends StatefulWidget {
  const RomanticMusicPlayer({super.key});

  @override
  State<RomanticMusicPlayer> createState() => _RomanticMusicPlayerState();
}

class _RomanticMusicPlayerState extends State<RomanticMusicPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Romantic song URL (Royalty free example, user should replace)
  final String _songUrl =
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

  @override
  void initState() {
    super.initState();

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _player.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _player.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(_songUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), // Glassmorphism
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Album Art / Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(width: 12),

          // Song Info & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Our Song 🎵",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble() > 0
                        ? _duration.inSeconds.toDouble()
                        : 1.0,
                    activeColor: Colors.pinkAccent,
                    inactiveColor: Colors.pink.shade100,
                    onChanged: (value) async {
                      await _player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
              ],
            ),
          ),

          // Controls
          IconButton(
            onPressed: _togglePlay,
            icon: Icon(
              _isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              size: 48,
              color: Colors.pinkAccent,
            ),
          ),
        ],
      ),
    );
  }
}
