import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_expense/model/expense_model.dart';

class ExpenseService {
  static const String _key = 'expenses';

  Future<void> saveExpense(Expense expense) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expenses = await getExpenses();
      expenses.add(expense);

      final encodedExpenses =
          expenses.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_key, encodedExpenses);
      print('Saved expense: ${expense.description}');
    } catch (e) {
      print('Error saving expense: $e');
      rethrow;
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedExpenses = prefs.getStringList(_key) ?? [];
      final expenses =
          encodedExpenses.map((e) => Expense.fromJson(jsonDecode(e))).toList();
      print('Retrieved ${expenses.length} expenses');
      return expenses;
    } catch (e) {
      print('Error getting expenses: $e');
      return [];
    }
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expenses = await getExpenses();

      final index = expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        expenses[index] = updatedExpense;
        final encodedExpenses =
            expenses.map((e) => jsonEncode(e.toJson())).toList();
        await prefs.setStringList(_key, encodedExpenses);
        print('Updated expense: ${updatedExpense.description}');
      }
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expenses = await getExpenses();

      expenses.removeWhere((expense) => expense.id == id);
      final encodedExpenses =
          expenses.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_key, encodedExpenses);
      print('Deleted expense with ID: $id');
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  Future<void> deleteAllExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      print('Deleted all expenses');
    } catch (e) {
      print('Error deleting all expenses: $e');
      rethrow;
    }
  }

  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    try {
      final expenses = await getExpenses();
      return expenses.where((expense) => expense.category == category).toList();
    } catch (e) {
      print('Error getting expenses by category: $e');
      return [];
    }
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses = await getExpenses();
      return expenses
          .where((expense) =>
              expense.date
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              expense.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    } catch (e) {
      print('Error getting expenses by date range: $e');
      return [];
    }
  }

  Future<bool> expenseExists(String id) async {
    try {
      final expenses = await getExpenses();
      return expenses.any((expense) => expense.id == id);
    } catch (e) {
      print('Error checking if expense exists: $e');
      return false;
    }
  }

  Future<Expense?> getExpenseById(String id) async {
    try {
      final expenses = await getExpenses();
      return expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      print('Error getting expense by ID: $e');
      return null;
    }
  }

  Future<double> getTotalExpensesForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses = await getExpensesByDateRange(startDate, endDate);
      return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      print('Error calculating total expenses for period: $e');
      return 0.0;
    }
  }
}
