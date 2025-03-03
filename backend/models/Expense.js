const mongoose = require('mongoose');

  const expenseSchema = new mongoose.Schema({
    userId: { type: String, required: true }, // Change to String
    amount: { type: Number, required: true },
    category: { type: String, required: true },
    date: { type: Date, default: Date.now },
    currency: { type: String, default: 'USD' }
  });

module.exports = mongoose.model('Expense', expenseSchema);