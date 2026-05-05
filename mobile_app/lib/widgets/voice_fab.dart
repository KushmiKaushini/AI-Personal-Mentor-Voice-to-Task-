import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class VoiceFab extends StatelessWidget {
  const VoiceFab({super.key});

  Future<void> _handleVoiceInput(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      // In a real app, you would upload this file to your backend
      // or process it locally using Gemini.
      // For now, we show a loading indicator and then refresh the tasks.
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing voice input...')),
      );

      // Simulate a delay for AI processing
      await Future.delayed(const Duration(seconds: 3));

      // Refresh tasks
      if (context.mounted) {
        await Provider.of<TaskProvider>(context, listen: false).fetchTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasks updated from voice!')),
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
