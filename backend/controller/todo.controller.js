const todoService = require('../services/todo.service');

// GET /api/todos
const getTodos = async (req, res) => {
    try {
        const userId = req.userId;
        const todos = await todoService.getTodos(userId);
        return res.status(200).json(todos);
    } catch (error) {
        return res.status(500).json({ error: 'Internal server error' });
    }
};

// POST /api/todos
const addTodo = async (req, res) => {
    try {
        const { todoTask } = req.body;
        const userId = req.userId;

        if (!todoTask || todoTask.trim() === '') {
            return res.status(400).json({ error: 'Todo task cannot be empty' });
        }

        const newTodo = await todoService.addTodo(todoTask.trim(), userId);
        return res.status(201).json(newTodo);
    } catch (error) {
        return res.status(500).json({ error: 'Internal server error' });
    }
};

// DELETE /api/todos/:id
const deleteTodo = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;

        const result = await todoService.deleteTodo(id, userId);
        return res.status(200).json(result);
    } catch (error) {
        if (error.message.includes('not found')) {
            return res.status(404).json({ error: error.message });
        }
        return res.status(500).json({ error: 'Internal server error' });
    }
};

module.exports = { getTodos, addTodo, deleteTodo };
