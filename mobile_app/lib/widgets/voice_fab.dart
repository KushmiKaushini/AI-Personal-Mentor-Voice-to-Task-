import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class VoiceFab extends StatelessWidget {
  const VoiceFab({super.key});

  Future<void> _handleVoiceInput(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.audio,
    );

    if (!context.mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing voice input...')),
      );

      if (!context.mounted) return;
      
      try {
        await Provider.of<TaskProvider>(context, listen: false)
            .processVoiceInput(result.files.single.path!);
            
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasks updated from voice!')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing voice: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () => _handleVoiceInput(context),
      backgroundColor: Colors.blueAccent,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.mic, color: Colors.white, size: 36),
        ),
      ),
    );
  }
}
