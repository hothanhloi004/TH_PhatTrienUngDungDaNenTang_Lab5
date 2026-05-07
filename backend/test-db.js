require('dotenv').config();
const mongoose = require('mongoose');

console.log('URI used:', process.env.MONGO_URI);

mongoose.connect(process.env.MONGO_URI)
    .then(() => {
        console.log('Successfully connected to MongoDB');
        process.exit(0);
    })
    .catch(err => {
        console.error('Connection error details:', err);
        process.exit(1);
    });
