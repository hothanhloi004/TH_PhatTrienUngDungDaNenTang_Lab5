const mongoose = require('mongoose');

const todoSchema = new mongoose.Schema(
    {
        todoTask: {
            type: String,
            required: [true, 'Todo task is required'],
            trim: true,
        },
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
    },
    { timestamps: true }
);

module.exports = mongoose.model('Todo', todoSchema);
