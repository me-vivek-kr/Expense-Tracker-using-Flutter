import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await _databaseHelper.getExpense();
    setState(() {
      _registeredExpenses.clear();
      _registeredExpenses.addAll(expenses);
    });
  }

  //Open the modal to add a new expense
  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: _addExpense,
      ),
    );
  }

  // Add expense to both the UI and the database
  Future<void> _addExpense(Expense expense) async {
    await _databaseHelper.insertExpense(expense);

    setState(() {
      _registeredExpenses.add(expense); // Add the expense to the local list
    });
  }

  Future<void> _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense Deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );

    // Wait for the snack bar duration before actually deleting from the database
    await Future.delayed(const Duration(seconds: 3));
    if (!_registeredExpenses.contains(expense)) {
      // Remove from database only if the user hasn't undone the delete
      await _databaseHelper.deleteExpense(int.parse(expense.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No Expenses Found, Start Addding Some!'),
    );
    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracker'),
          actions: [
            IconButton(
              onPressed: _openAddExpenseOverlay,
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: width < 600
            ? Column(
                children: [
                  Chart(expenses: _registeredExpenses),
                  Expanded(
                    child: mainContent,
                  )
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Chart(expenses: _registeredExpenses),
                  ),
                  Expanded(
                    child: mainContent,
                  ),
                ],
              ));
  }
}
