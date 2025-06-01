import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskScreen extends StatefulWidget {
	const TaskScreen({super.key});

	@override
	State<TaskScreen> createState() => _TaskScreenState();
}
class _TaskScreenState extends State<TaskScreen> {
  final List<Task> _tasks = [
    Task(title: 'Buy groceries'),
    Task(title: 'Finish Flutter UI'),
    Task(title: 'Sync with Google Calendar'),
];

	void _toggleTask(int index){
	setState((){
		_tasks[index].toggleDone();
});
	}

@override
Widget build(BuildContext context){
		return Scaffold(
		  appBar:AppBar(
		   title:const Text ('Advanced Todo Planner'),
),
body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Checkbox(
              value: task.isDone,
              onChanged: (value) => _toggleTask(index),
            ),
          );
        },
      ),
	floatingActionButton: FloatingActionButton(
			onPressed: _showAddTaskDialog,
			child: Icon(Icons.add),
    ),
    );
}
