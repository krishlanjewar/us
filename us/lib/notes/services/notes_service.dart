import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:us/notes/models/note_model.dart';
import 'package:image_picker/image_picker.dart';

class NotesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- 1. GET NOTES (Stream) ---
  // Returns a real-time stream of notes for the current user
  Stream<List<Note>> getNotesStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId) // Only filter my notes
        .order('selected_date', ascending: false) // Newest dates first
        .map((data) => data.map((json) => Note.fromJson(json)).toList());
  }

  // --- 2. CREATE NOTE ---
  // Uploads images first, then saves the note data
  Future<void> createNote({
    required String content,
    required DateTime selectedDate,
    required List<XFile> images,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    try {
      // Step A: Upload Images to Supabase Storage
      List<String> uploadedImageUrls = [];

      for (var image in images) {
        final imageUrl = await _uploadImage(image);
        if (imageUrl != null) {
          uploadedImageUrls.add(imageUrl);
        }
      }

      // Step B: Insert Note into Database
      await _supabase.from('notes').insert({
        'user_id': userId,
        'content': content,
        'selected_date': selectedDate.toIso8601String(),
        'image_urls': uploadedImageUrls,
      });
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  // --- 3. HELPER: UPLOAD IMAGE ---
  // Uploads a single file and returns the public URL
  Future<String?> _uploadImage(XFile imageFile) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      // Create a unique filename: userid_timestamp.jpg
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final filePath = 'uploads/$fileName'; // Folder structure in bucket

      final File file = File(imageFile.path);

      // Upload to Supabase Storage bucket named 'note_images'
      await _supabase.storage
          .from('note_images')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get the public URL to save in the database
      final publicUrl = _supabase.storage
          .from('note_images')
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // --- 4. DELETE NOTE ---
  Future<void> deleteNote(String noteId) async {
    await _supabase.from('notes').delete().eq('id', noteId);
  }
}
