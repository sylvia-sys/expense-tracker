import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
      ),
      home: ExpenseListScreen(),
    );
  }
}

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<dynamic> expenses = [];
  double totalSpending = 0.0;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/expenses/123'));
    if (response.statusCode == 200) {
      setState(() {
        expenses = json.decode(response.body);
        totalSpending = expenses.fold(0.0, (sum, expense) => sum + expense['amount']);
      });
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _amountController = TextEditingController();
    final _categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Add the expense to the backend
                  final response = await http.post(
                    Uri.parse('http://localhost:5000/api/expenses'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'userId': '123',
                      'amount': double.parse(_amountController.text),
                      'category': _categoryController.text,
                      'currency': 'USD',
                    }),
                  );

                  if (response.statusCode == 201) {
                    fetchExpenses(); // Refresh the expense list
                    Navigator.pop(context); // Close the dialog
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchExpenses,
          ),
        ],
      ),
      body: Column(
        children: [
          // Analytics Dashboard
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spending: \$${totalSpending.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: _buildBarGroups(),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expense List
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      '\$${expense['amount']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Category: ${expense['category']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: Icon(Icons.arrow_forward, color: Colors.blue),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseDialog(context); // Open the add expense dialog
        },
        child: Icon(Icons.add),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return expenses.map((expense) {
      return BarChartGroupData(
        x: expenses.indexOf(expense),
        barRods: [
          BarChartRodData(
            toY: expense['amount'].toDouble(), // Use `toY` instead of `y`
            color: Colors.blue, // Use `color` instead of `colors`
          ),
        ],
      );
    }).toList();
  }
}