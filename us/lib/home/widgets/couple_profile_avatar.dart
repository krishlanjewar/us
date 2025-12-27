import 'dart:typed_data'; // for Uint8List
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CoupleProfileAvatar extends StatefulWidget {
  final double size; // allows you to change the avatar size anywhere
  final String? imageUrl; // optional for future online image

  const CoupleProfileAvatar({super.key, this.size = 120, this.imageUrl});

  @override
  State<CoupleProfileAvatar> createState() => _CoupleProfileAvatarState();
}

class _CoupleProfileAvatarState extends State<CoupleProfileAvatar> {
  Uint8List? _imageBytes; // Store bytes to support Web & Mobile
  bool _isPressed = false; // for the small tap animation

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // This function lets user pick image from gallery
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double borderWidth = 4.0;

    return GestureDetector(
      onTapDown: (_) =>
          setState(() => _isPressed = true), // start scale animation
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () async {
        // if no image, allow to pick one
        if (_imageBytes == null && widget.imageUrl == null) {
          await _pickImage();
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0, // smooth zoom on tap
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFC1E3),
                Color(0xFFF48FB1),
              ], // Soft pink gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.white, width: borderWidth),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              2.0,
            ), // Gap between border and content
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildInnerContent(), // shows image or + icon
            ),
          ),
        ),
      ),
    );
  }

  // Decides what to show inside the circle
  Widget _buildInnerContent() {
    // 1️⃣ If local image picked (Bytes)
    if (_imageBytes != null) {
      return Image.memory(_imageBytes!, fit: BoxFit.cover);
    }

    // 2️⃣ If future network image is provided
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return Image.network(
        widget.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          );
        },
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.error, color: Colors.redAccent)),
      );
    }

    // 3️⃣ Empty state → show Heart icon
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: widget.size * 0.4,
              color: Colors.pinkAccent.shade100,
            ),
            Text(
              "Add Photo",
              style: TextStyle(
                fontSize: 10,
                color: Colors.pinkAccent.shade100,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
