const express = require('express');
const Expense = require('../models/Expense');
const router = express.Router();

// Add an expense
router.post('/', async (req, res) => {
  try {
    const { userId, amount, category, currency } = req.body;
    const expense = new Expense({ userId, amount, category, currency });
    await expense.save();
    res.status(201).json(expense);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Get all expenses for a user
router.get('/:userId', async (req, res) => {
  try {
    const expenses = await Expense.find({ userId: req.params.userId });
    res.json(expenses);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;