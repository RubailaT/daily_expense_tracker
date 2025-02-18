import 'package:personal_expense/model/expense_model.dart';

class StatisticsService {
  Map<ExpenseCategory, double> getCategoryTotals(List<Expense> expenses) {
    final totals = <ExpenseCategory, double>{};

    // Initialize all categories with 0
    for (var category in ExpenseCategory.values) {
      totals[category] = 0.0;
    }

    // Sum up expenses for each category
    for (var expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }

    return totals;
  }

  double getTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<DateTime, double> getDailyTotals(List<Expense> expenses) {
    final dailyTotals = <DateTime, double>{};

    for (var expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0.0) + expense.amount;
    }

    return dailyTotals;
  }

  // Additional helper methods
  double getAverageExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    return getTotalExpenses(expenses) / expenses.length;
  }

  Map<int, double> getMonthlyTotals(List<Expense> expenses) {
    final monthlyTotals = <int, double>{};

    for (var expense in expenses) {
      final month = expense.date.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0.0) + expense.amount;
    }

    return monthlyTotals;
  }

  double getCategoryTotal(List<Expense> expenses, ExpenseCategory category) {
    return expenses
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
