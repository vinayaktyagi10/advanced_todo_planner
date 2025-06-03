import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskScreen extends StatefulWidget {
	const TaskScreen({super.key});

	@override
	State<TaskScreen> createState() => _TaskScreenState();
}
class _TaskScreenState extends State<TaskScreen> {	//testing what we see when these tasks are given by the system so as to see what tweaking does.
late Box<Task> taskBox;
bool _isBoxReady=false;
@override
void initState(){
	super.initState();
	taskBox = Hive.box<Task>('tasks');
	_removeExpiredTasks();
	setState((){
	_isBoxReady=true;
	});
	}

void _removeExpiredTasks(){
	final now = DateTime.now();
	for(int i=taskBox.length-1;i>=0;i--){
	final task=taskBox.getAt(i);
	if(task!=null && task.isDone && now.difference(task.createdAt).inHours>=24){
	taskBox.deleteAt(i);
	}
   }
}
TaskPriority _selectedPriority=TaskPriority.medium;
void _showAddTaskDialog() {
  String newTaskTitle = '';
  TaskPriority newTaskPriority = TaskPriority.medium;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add New Task'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(hintText: 'Enter task'),
                    onChanged: (value) {
                      newTaskTitle = value;
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        taskBox.add(Task(
                          title: value.trim(),
                          priority: newTaskPriority,
                        ));
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<TaskPriority>(
                    value: newTaskPriority,
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          newTaskPriority = value;
                        });
                      }
                    },
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem<TaskPriority>(
                        value: priority,
                        child: Text(priority.name.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // cancel
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (newTaskTitle.trim().isNotEmpty) {
                    taskBox.add(Task(
                      title: newTaskTitle.trim(),
                      priority: newTaskPriority,
                    ));
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}


void _showEditTaskDialog(Task task, int index) {
  String updatedTitle = task.title;
  TaskPriority updatedPriority = task.priority ?? TaskPriority.medium;
  final controller = TextEditingController(text: task.title);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Task'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  updatedTitle = value;
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    task.title = value.trim();
                    task.priority = updatedPriority;
                    task.save();
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButton<TaskPriority>(
                value: updatedPriority,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      updatedPriority = value;
                    });
                  }
                },
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(priority.name.toUpperCase()),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (updatedTitle.trim().isNotEmpty) {
                task.title = updatedTitle.trim();
                task.priority = updatedPriority;
                await task.save();
                await taskBox.putAt(index, task);
                setState(() {});
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void _toggleTask(Task task) async {
  task.toggleDone();
  await task.save();

  final allTasks = taskBox.values.toList();
  allTasks.sort((a, b) {
    if (!a.isDone && b.isDone) return -1;
    if (a.isDone && !b.isDone) return 1;
    return 0;
  });

  await taskBox.clear();
  for (final t in allTasks) {
    await taskBox.add(t);
  }
}
	void _onReorder(int oldIndex, int newIndex) //start HERE
	async{
			final tasks=taskBox.values.toList();
			if(newIndex>oldIndex){
			newIndex-=1;
			}
			final task= tasks.removeAt(oldIndex);
			tasks.insert(newIndex, task);
			await taskBox.clear();
			for(final t in tasks){
			await taskBox.add(t);
		}
	       }


@override
Widget build(BuildContext context) {
  if(!_isBoxReady){
  return const Scaffold(
  	body: Center(child: CircularProgressIndicator()),
  );
  }
return Scaffold(
    body: ValueListenableBuilder<Box<Task>>(
      valueListenable: taskBox.listenable(),
      builder: (context, box, _) {
        final tasks = box.values.toList();

        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks yet!'));
        }

        return ReorderableListView.builder(
          itemCount: tasks.length,
	onReorder: _onReorder,
          itemBuilder: (context, index) {
            final task = tasks[index];
	return Card(
	
	key: ValueKey(task.key),
	
  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
		color: task.isDone ? Colors.grey : Colors.black87,
        	fontSize: 18,
                ),
	       ),
		onTap:(){
		_showEditTaskDialog(task, index);
									},
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: task.isDone,
                    onChanged: (value) {
			_toggleTask(task);
                    },
                  ),
                  IconButton(
		icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      box.deleteAt(index);
                    },
                  ),
                ],
              ),
	     ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddTaskDialog,
      child: const Icon(Icons.add),
    ),
  );
}
}

