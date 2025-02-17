import 'package:personal_expense/model/expense_model.dart';

class StatisticsService {
  Map<ExpenseCategory, double> getCategoryTotals(List<Expense> expenses) {
    final totals = <ExpenseCategory, double>{};
    for (var category in ExpenseCategory.values) {
      totals[category] = expenses
          .where((e) => e.category == category)
          .fold(0, (sum, expense) => sum + expense.amount);
    }
    return totals;
  }

  double getTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<DateTime, double> getDailyTotals(List<Expense> expenses) {
    final dailyTotals = <DateTime, double>{};
    for (var expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0) + expense.amount;
    }
    return dailyTotals;
  }
}
