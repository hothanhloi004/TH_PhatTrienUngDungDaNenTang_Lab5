const express = require('express');
const router = express.Router();
const { getTodos, addTodo, deleteTodo } = require('../controller/todo.controller');
const { verifyToken } = require('../middleware/auth.middleware');

// All todo routes are protected by JWT middleware
router.use(verifyToken);

// GET /api/todos
router.get('/', getTodos);

// POST /api/todos
router.post('/', addTodo);

// DELETE /api/todos/:id
router.delete('/:id', deleteTodo);

module.exports = router;
