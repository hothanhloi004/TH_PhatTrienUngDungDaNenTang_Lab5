const userService = require('../services/user.service');

// POST /api/users/register
const register = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        if (password.length < 6) {
            return res.status(400).json({ error: 'Password must be at least 6 characters' });
        }

        const result = await userService.registerUser(email, password);
        return res.status(201).json(result);
    } catch (error) {
        if (error.message.includes('already exists')) {
            return res.status(409).json({ error: error.message });
        }
        return res.status(500).json({ error: 'Internal server error' });
    }
};

// POST /api/users/login
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        const result = await userService.loginUser(email, password);
        return res.status(200).json(result);
    } catch (error) {
        if (error.message.includes('Invalid')) {
            return res.status(401).json({ error: error.message });
        }
        return res.status(500).json({ error: 'Internal server error' });
    }
};

module.exports = { register, login };
