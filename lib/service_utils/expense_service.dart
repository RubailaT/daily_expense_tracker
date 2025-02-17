import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../model/expense_model.dart';

class ExpenseService {
  static const String _key = 'expenses';

  Future<void> saveExpense(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    expenses.add(expense);

    final encodedExpenses =
        expenses.map((expense) => jsonEncode(expense.toJson())).toList();

    await prefs.setStringList(_key, encodedExpenses);
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();

    final index = expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      expenses[index] = updatedExpense;

      final encodedExpenses =
          expenses.map((expense) => jsonEncode(expense.toJson())).toList();

      await prefs.setStringList(_key, encodedExpenses);
    }
  }

  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedExpenses = prefs.getStringList(_key) ?? [];

    return encodedExpenses.map((e) => Expense.fromJson(jsonDecode(e))).toList();
  }

  Future<void> deleteExpense(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    expenses.removeWhere((expense) => expense.id == id);

    final encodedExpenses =
        expenses.map((expense) => jsonEncode(expense.toJson())).toList();

    await prefs.setStringList(_key, encodedExpenses);
  }

  Future<void> deleteAllExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    final expenses = await getExpenses();
    return expenses.where((expense) => expense.category == category).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses = await getExpenses();
    return expenses
        .where((expense) =>
            expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }
}
