const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/user.model');

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key_here';

// Register a new user
const registerUser = async (email, password) => {
    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
        throw new Error('User with this email already exists');
    }

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create and save user
    const newUser = new User({ email, password: hashedPassword });
    await newUser.save();

    return { message: 'User registered successfully', userId: newUser._id };
};

// Login user and return JWT token
const loginUser = async (email, password) => {
    // Find user
    const user = await User.findOne({ email });
    if (!user) {
        throw new Error('Invalid email or password');
    }

    // Compare password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
        throw new Error('Invalid email or password');
    }

    // Generate JWT token (expires in 1 hour)
    const token = jwt.sign(
        { userId: user._id, email: user.email },
        JWT_SECRET,
        { expiresIn: '1h' }
    );

    return { token, userId: user._id };
};

module.exports = { registerUser, loginUser };
