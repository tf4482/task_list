import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TaskStorage _storage = TaskStorage();
  
  RenewalType _selectedRenewalType = RenewalType.none;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedRenewalType = widget.task!.renewalType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.task == null) {
        // Create new task
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          renewalType: _selectedRenewalType,
        );
        await _storage.addTask(newTask);
      } else {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          renewalType: _selectedRenewalType,
        );
        
        // Recalculate next renewal date if renewal type changed
        if (updatedTask.renewalType != widget.task!.renewalType) {
          updatedTask.nextRenewalDate = null;
          updatedTask.lastRenewalDate = null;
          if (updatedTask.renewalType != RenewalType.none) {
            final now = DateTime.now();
            switch (updatedTask.renewalType) {
              case RenewalType.daily:
                updatedTask.nextRenewalDate = DateTime(now.year, now.month, now.day + 1);
                break;
              case RenewalType.weekly:
                updatedTask.nextRenewalDate = DateTime(now.year, now.month, now.day + 7);
                break;
              case RenewalType.monthly:
                updatedTask.nextRenewalDate = DateTime(now.year, now.month + 1, now.day);
                break;
              case RenewalType.none:
                break;
            }
          }
        }
        
        await _storage.updateTask(updatedTask);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                autofocus: !isEditing,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              const Text(
                'Renewal Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: RenewalType.values.map((type) {
                      return RadioListTile<RenewalType>(
                        title: Text(type.displayName),
                        subtitle: type != RenewalType.none
                            ? Text(_getRenewalDescription(type))
                            : null,
                        value: type,
                        groupValue: _selectedRenewalType,
                        onChanged: (value) {
                          setState(() {
                            _selectedRenewalType = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_selectedRenewalType != RenewalType.none)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This task will automatically reset to incomplete ${_selectedRenewalType.displayName.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Task' : 'Add Task',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRenewalDescription(RenewalType type) {
    switch (type) {
      case RenewalType.daily:
        return 'Task resets every day';
      case RenewalType.weekly:
        return 'Task resets every week';
      case RenewalType.monthly:
        return 'Task resets every month';
      case RenewalType.none:
        return '';
    }
  }
}