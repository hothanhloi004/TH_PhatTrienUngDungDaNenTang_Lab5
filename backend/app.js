const express = require('express');
const cors = require('cors');
require('dotenv').config();

const connectDB = require('./config/db');
const userRoutes = require('./routes/user.routes');
const todoRoutes = require('./routes/todo.routes');

const app = express();

// Connect to MongoDB
connectDB();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/users', userRoutes);
app.use('/api/todos', todoRoutes);

// Health check
app.get('/', (req, res) => {
    res.json({ message: 'Todo API is running!' });
});

module.exports = app;
