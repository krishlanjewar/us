import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:us/notes/models/note_model.dart';
import 'package:us/notes/services/notes_service.dart';

class NotesListPage extends StatelessWidget {
  NotesListPage({super.key});

  final _notesService = NotesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5), // Lavender Blush
      appBar: AppBar(
        title: const Text(
          'Our Love Notes 💕',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink[300],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Note page
          Navigator.pushNamed(context, '/create_note');
        },
        backgroundColor: Colors.pink[400],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _notesService.getNotesStream(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading notes: ${snapshot.error}'),
            );
          }

          // 3. Data State
          final notes = snapshot.data ?? [];

          // 4. Empty State
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.pink[200],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet. Create your first memory! ✨',
                    style: TextStyle(color: Colors.pink[300], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 5. List of Notes
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _buildNoteCard(context, note);
            },
          );
        },
      ),
    );
  }

  // --- WIDGET: Note Card ---
  Widget _buildNoteCard(BuildContext context, Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.pink.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Colors.pink),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(note.selectedDate),
                  style: TextStyle(
                    color: Colors.pink[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Delete button (optional - for now simplified)
                // Icon(Icons.more_vert, color: Colors.pink[300], size: 20),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    // Confirm delete
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete Note?'),
                        content: const Text(
                          'Are you sure you want to delete this memory?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              _notesService.deleteNote(note.id);
                              Navigator.pop(c);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Body: Text Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              note.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Body: Images (Horizontal Scroll if multiple)
          if (note.imageUrls.isNotEmpty)
            Container(
              height: 200,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: note.imageUrls.length,
                itemBuilder: (context, imgIndex) {
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(note.imageUrls[imgIndex]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
