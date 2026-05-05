class Task {
  final int? id;
  final String subject;
  final String taskName;
  final String? description;
  final String? deadline;
  final DateTime? createdAt;
  final String status;

  Task({
    this.id,
    required this.subject,
    required this.taskName,
    this.description,
    this.deadline,
    this.createdAt,
    this.status = 'pending',
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      subject: json['subject'],
      taskName: json['task_name'],
      description: json['description'],
      deadline: json['deadline'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'task_name': taskName,
      'description': description,
      'deadline': deadline,
      'status': status,
    };
  }
}
