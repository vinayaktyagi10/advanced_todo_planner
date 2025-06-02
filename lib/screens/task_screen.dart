import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskScreen extends StatefulWidget {
	const TaskScreen({super.key});

	@override
	State<TaskScreen> createState() => _TaskScreenState();
}
class _TaskScreenState extends State<TaskScreen> {	//testing what we see when these tasks are given by the system so as to see what tweaking does.
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
	
	void _showAddTaskDialog(){
	 String newTaskTitle=' ';	//assigns a temp. variable to add a new task.
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
				 setState(() {
				  _tasks.add(Task(title: value.trim()));
				  });
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
  onPressed: (){
	if (newTaskTitle.trim().isNotEmpty){    //avoids empty entry
	 setState((){
	   _tasks.add(Task(title: newTaskTitle.trim()));
	}); //this adds a new task if #valid#
	}
	Navigator.of(context).pop(); //closes the dialog again
	},
	child: const Text('Add'),
),
],
);
},
);
}

	

@override
	void initState(){
		super.initState();
		_removeExpiredTasks();
	}
	void _removeExpiredTasks(){
		setState((){
		 _tasks.removeWhere((task) =>
		task.isDone && DateTime.now().difference(task.createdAt).inHours>=24);
});
	}
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
          trailing: Row( // lets you add things to the tasks
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: task.isDone,
                onChanged: (value) => _toggleTask(index),
              ),
              IconButton( // adds a delete button
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _tasks.removeAt(index);
                  });
                },
              ),
            ],
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton( // lets you add tasks using the '+' button 
      onPressed: _showAddTaskDialog,
      child: Icon(Icons.add),
    ),
  ); 
}
}
