class Task {
  final String title;
  bool isDone;
  final DateTime createdAt;

  Task({required this.title, this.isDone = false})
	: createdAt = DateTime.now();

  void toggleDone() {
    isDone = !isDone;
  }
}

