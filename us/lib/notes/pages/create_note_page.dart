import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:us/notes/services/notes_service.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  // --- CONTROLLERS & STATE ---
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;

  final _notesService = NotesService();
  final _imagePicker = ImagePicker();

  // --- METHODS ---

  // 1. Pick Image
  Future<void> _pickImage() async {
    try {
      // Pick a single image (could be multi-image in future)
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // 2. Pick Date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.pink[800]!, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 3. Save Note
  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first! 💕')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _notesService.createNote(
        content: _contentController.text,
        selectedDate: _selectedDate,
        images: _selectedImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully! 💕')),
        );
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5), // Lavender Blush (Light Pink)
      appBar: AppBar(
        title: const Text(
          'New Romantic Note',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink[300],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Save Button
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- DATE SELECTOR ---
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink[100]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.pink),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: TextStyle(
                        color: Colors.pink[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- TEXT INPUT ---
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "Write your romantic thoughts here... ✨",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),

            // --- IMAGES SECTION ---
            Text(
              'Memories (Images)',
              style: TextStyle(
                color: Colors.pink[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Image List (Horizontal Scroll)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1, // +1 for "Add" button
                itemBuilder: (context, index) {
                  // "Add Image" Button at the end
                  if (index == _selectedImages.length) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.pink[200]!,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo, color: Colors.pink),
                            SizedBox(height: 4),
                            Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.pink,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Selected Image Thumbnails
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_selectedImages[index].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Delete X button
                      Positioned(
                        top: 4,
                        right: 16, // Adjust for margin
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
