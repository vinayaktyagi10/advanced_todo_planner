import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  TaskPriority? priority;

  Task({
required this.title,
    this.isDone = false,
    TaskPriority? priority,  // nullable param
  })  : createdAt = DateTime.now(),
        priority = priority ?? TaskPriority.medium;

  void toggleDone() {
    isDone = !isDone;
  }
}
