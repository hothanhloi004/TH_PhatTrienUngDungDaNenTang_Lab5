const Todo = require('../models/todo.model');

// Get all todos for a user
const getTodos = async (userId) => {
    const todos = await Todo.find({ userId }).sort({ createdAt: -1 });
    return todos;
};

// Add a new todo
const addTodo = async (todoTask, userId) => {
    const newTodo = new Todo({ todoTask, userId });
    await newTodo.save();
    return newTodo;
};

// Delete a todo by ID
const deleteTodo = async (todoId, userId) => {
    const todo = await Todo.findOneAndDelete({ _id: todoId, userId });
    if (!todo) {
        throw new Error('Todo not found or unauthorized');
    }
    return { message: 'Todo deleted successfully' };
};

module.exports = { getTodos, addTodo, deleteTodo };
