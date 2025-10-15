import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorage {
  static const String _tasksKey = 'tasks';
  
  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      
      if (tasksJson == null || tasksJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = json.decode(tasksJson);
      return decoded.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }
  
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
      return await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      print('Error saving tasks: $e');
      return false;
    }
  }
  
  Future<bool> addTask(Task task) async {
    final tasks = await loadTasks();
    tasks.add(task);
    return await saveTasks(tasks);
  }
  
  Future<bool> updateTask(Task updatedTask) async {
    final tasks = await loadTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    
    if (index != -1) {
      tasks[index] = updatedTask;
      return await saveTasks(tasks);
    }
    
    return false;
  }
  
  Future<bool> deleteTask(String taskId) async {
    final tasks = await loadTasks();
    tasks.removeWhere((task) => task.id == taskId);
    return await saveTasks(tasks);
  }
  
  Future<List<Task>> checkAndRenewTasks() async {
    final tasks = await loadTasks();
    bool hasChanges = false;
    
    for (var task in tasks) {
      if (task.shouldRenew()) {
        task.renewTask();
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      await saveTasks(tasks);
    }
    
    return tasks;
  }
  
  Future<bool> clearAllTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tasksKey);
    } catch (e) {
      print('Error clearing tasks: $e');
      return false;
    }
  }
}