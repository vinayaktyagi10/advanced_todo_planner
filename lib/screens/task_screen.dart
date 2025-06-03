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

void _showAddTaskDialog(){
String newTaskTitle='';	//assigns a temp. variable to add a new task.
showDialog(
context: context,
builder:(context){
	return AlertDialog(	//this lets you add a task.
	title: const Text('Add New Task'),
		content: TextField(
	 	autofocus: true,
	 	decoration: const InputDecoration(hintText: 'Enter task'),
	 	onChanged: (value){
	  	newTaskTitle = value;
		},
		onSubmitted:(value) {  //lets you add using enter
			if (value.trim().isNotEmpty){
			 taskBox.add(Task(title: value.trim()));
				Navigator.of(context).pop();
				}
			},
      		),
	actions: [
	TextButton(
	 onPressed: (){
	  Navigator.of(context).pop();		//closes the dialog without adding a new task.
},
child: const Text('Cancel'),
),
TextButton(
              onPressed: () {
                if (newTaskTitle.trim().isNotEmpty) {
                  taskBox.add(Task(title: newTaskTitle.trim()));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
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
    appBar: AppBar(
      title: const Text('Advanced Todo Planner'),
    ),
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
            return ListTile(
		key: ValueKey(task.key),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
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
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      box.deleteAt(index);
                    },
                  ),
                ],
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

