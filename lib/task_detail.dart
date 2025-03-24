import 'package:flutter/material.dart';
import 'task.dart';
import 'add_task.dart';

class TaskDetail extends StatefulWidget {
  final Task task;
  final Function(Task) onUpdate;
  final VoidCallback onDelete;

  TaskDetail({
    Key? key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  @override
  void didUpdateWidget(TaskDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.id != oldWidget.task.id ||
        widget.task.title != oldWidget.task.title ||
        widget.task.description != oldWidget.task.description ||
        widget.task.isCompleted != oldWidget.task.isCompleted) {
      _currentTask = widget.task;
    }
  }

  void _handleTaskUpdate(Task updatedTask) {
    widget.onUpdate(updatedTask);
    setState(() {
      _currentTask = updatedTask;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Edit Task',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AddTask(
                        onAdd: _handleTaskUpdate,
                        taskToEdit: _currentTask,
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete Task',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text('Delete Task'),
                    content: Text(
                      'Are you sure you want to delete "${_currentTask.title}"?',
                    ),
                    actions: [
                      TextButton(
                        child: Text('CANCEL'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: Text('DELETE'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          widget.onDelete();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _currentTask.isCompleted ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _currentTask.isCompleted ? 'Completed' : 'In Progress',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            Text(
              _currentTask.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                decoration:
                    _currentTask.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
              ),
            ),
            SizedBox(height: 8),
            Divider(),
            if (_currentTask.description.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.description, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentTask.description,
                  style: TextStyle(
                    fontSize: 16,
                    decoration:
                        _currentTask.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Divider(),
            ],
            if (_currentTask.deadline != null ||
                _currentTask.dueTime != null) ...[
              Row(
                children: [
                  Icon(Icons.event, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Deadline:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentTask.deadline != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Date: ${_currentTask.getDueDateString()}',
                            style: TextStyle(
                              fontSize: 16,
                              decoration:
                                  _currentTask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    if (_currentTask.deadline != null &&
                        _currentTask.dueTime != null)
                      SizedBox(height: 4),
                    if (_currentTask.dueTime != null)
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Time: ${_currentTask.getDueTimeString()}',
                            style: TextStyle(
                              fontSize: 16,
                              decoration:
                                  _currentTask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Divider(),
            ],
            if (_currentTask.subTasks.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.checklist, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Sub-Tasks (${_currentTask.subTasks.where((st) => st.isCompleted).length}/${_currentTask.subTasks.length}):',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children:
                      _currentTask.subTasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subTask = entry.value;
                        return CheckboxListTile(
                          title: Text(
                            subTask.title,
                            style: TextStyle(
                              decoration:
                                  subTask.isCompleted ||
                                          _currentTask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          value: subTask.isCompleted,
                          activeColor: Colors.green,
                          onChanged:
                              _currentTask.isCompleted
                                  ? null
                                  : (bool? value) {
                                    if (value != null) {
                                      final updatedSubTasks =
                                          List<SubTask>.from(
                                            _currentTask.subTasks,
                                          );
                                      updatedSubTasks[index].isCompleted =
                                          value;
                                      final updatedTask = Task(
                                        id: _currentTask.id,
                                        title: _currentTask.title,
                                        description: _currentTask.description,
                                        isCompleted: _currentTask.isCompleted,
                                        deadline: _currentTask.deadline,
                                        dueTime: _currentTask.dueTime,
                                        subTasks: updatedSubTasks,
                                      );
                                      _handleTaskUpdate(updatedTask);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            value
                                                ? 'Sub-task marked as completed'
                                                : 'Sub-task marked as incomplete',
                                          ),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                        );
                      }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(_currentTask.isCompleted ? Icons.refresh : Icons.check),
        label: Text(
          _currentTask.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
        ),
        backgroundColor:
            _currentTask.isCompleted ? Colors.orange : Colors.green,
        onPressed: () {
          final List<SubTask> updatedSubTasks =
              _currentTask.subTasks.map((subTask) {
                if (!_currentTask.isCompleted) {
                  return SubTask(title: subTask.title, isCompleted: true);
                }
                return SubTask(
                  title: subTask.title,
                  isCompleted: subTask.isCompleted,
                );
              }).toList();
          final updatedTask = Task(
            id: _currentTask.id,
            title: _currentTask.title,
            description: _currentTask.description,
            isCompleted: !_currentTask.isCompleted,
            deadline: _currentTask.deadline,
            dueTime: _currentTask.dueTime,
            subTasks: updatedSubTasks,
          );
          _handleTaskUpdate(updatedTask);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updatedTask.isCompleted
                    ? 'Task "${_currentTask.title}" marked as completed'
                    : 'Task "${_currentTask.title}" marked as incomplete',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
