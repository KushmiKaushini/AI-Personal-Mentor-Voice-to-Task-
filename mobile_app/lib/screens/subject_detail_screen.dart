import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class SubjectDetailScreen extends StatelessWidget {
  final String subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final subjectTasks = taskProvider.getTasksBySubject(subject);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          subject,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.iconTheme?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have ${subjectTasks.length} active tasks for this subject.',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: subjectTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: GoogleFonts.outfit(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: subjectTasks.length,
                    itemBuilder: (context, index) {
                      final task = subjectTasks[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 50 * index),
                        child: _buildDismissibleTask(context, task, taskProvider),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleTask(BuildContext context, Task task, TaskProvider taskProvider) {
    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          taskProvider.updateTaskStatus(task.id!, 'completed');
        } else {
          taskProvider.deleteTask(task.id!);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm"),
                content: const Text("Are you sure you want to delete this task?"),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("CANCEL")),
                  TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
                ],
              );
            },
          );
        }
        return true;
      },
      background: _buildSwipeBackground(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        icon: Icons.check_circle,
        label: 'Complete',
      ),
      secondaryBackground: _buildSwipeBackground(
        color: Colors.red,
        alignment: Alignment.centerRight,
        icon: Icons.delete,
        label: 'Delete',
      ),
      child: _buildTaskTile(context, task),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required Alignment alignment,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
          ] else ...[
            Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, color: color),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = task.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted ? theme.colorScheme.surface.withOpacity(0.5) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Opacity(
        opacity: isCompleted ? 0.5 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.taskName,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (task.deadline != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.grey.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.deadline!,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isCompleted ? Colors.grey : (isDark ? Colors.blueAccent : Colors.blue),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                task.description!,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  height: 1.5,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
