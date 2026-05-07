import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'loginPage.dart';

class Dashboard extends StatefulWidget {
  final String token;

  const Dashboard({super.key, required this.token});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<dynamic> _todos = [];
  bool _isLoading = false;
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _initDashboard() {
    // Check token expiry
    if (JwtDecoder.isExpired(widget.token)) {
      _logout();
      return;
    }

    _fetchTodos();
  }

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      };

  Future<void> _fetchTodos() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(Config.todoUrl),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        setState(() => _todos = jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching todos: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTodo(String task) async {
    try {
      final response = await http.post(
        Uri.parse(Config.todoUrl),
        headers: _authHeaders,
        body: jsonEncode({'todoTask': task}),
      );

      if (response.statusCode == 201) {
        _fetchTodos();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Failed to add todo'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding todo: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _deleteTodo(String todoId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Config.todoUrl}/$todoId'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        _fetchTodos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todo deleted'), backgroundColor: Color(0xFF4CAF50)),
          );
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting todo: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _handleUnauthorized() {
    _logout(message: 'Session expired. Please login again.');
  }

  Future<void> _logout({String? message}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (mounted) {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.orangeAccent),
        );
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showAddTodoDialog() {
    _todoController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Add New Todo',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: TextField(
          controller: _todoController,
          style: const TextStyle(color: Color(0xFF1A1A1A)),
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            hintText: 'Enter your task...',
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
            filled: true,
            fillColor: const Color(0xFFF0F4F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                final task = _todoController.text.trim();
                if (task.isNotEmpty) {
                  Navigator.pop(context);
                  _addTodo(task);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF42A5F5),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(28, 60, 20, 30),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.list, color: Colors.white, size: 28),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      onPressed: () => _logout(),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'ToDo with NodeJs + Mongodb',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_todos.length} Task',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // Body List Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _todos.isEmpty
                        ? _buildEmptyState()
                        : _buildTodoList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes_rounded, size: 70, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Keep it up!',
            style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return RefreshIndicator(
      onRefresh: _fetchTodos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          final todoId = todo['_id'] as String;
          final todoTask = todo['todoTask'] as String;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Slidable(
              key: ValueKey(todoId),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.3,
                children: [
                  SlidableAction(
                    onPressed: (_) => _deleteTodo(todoId),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    borderRadius: BorderRadius.circular(16),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description, color: Colors.grey, size: 28),
                  title: Text(
                    todoTask,
                    style: const TextStyle(
                      color: Color(0xFF2D3436),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_back, color: Colors.grey, size: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
