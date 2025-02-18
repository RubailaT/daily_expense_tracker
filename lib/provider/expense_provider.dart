import 'package:flutter/foundation.dart';
import 'package:personal_expense/model/expense_model.dart';
import 'package:personal_expense/service_utils/expense_service.dart';
import 'package:personal_expense/service_utils/statistics_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final StatisticsService _statisticsService = StatisticsService();

  List<Expense> _expenses = [];
  ExpenseCategory? _selectedCategory;
  String _searchQuery = '';
  String _sortBy = 'date';

  // Getters
  List<Expense> get expenses => _expenses;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  // Statistics getters
  Map<ExpenseCategory, double> get categoryTotals =>
      _statisticsService.getCategoryTotals(_expenses);

  double get totalExpenses => _statisticsService.getTotalExpenses(_expenses);

  double getAverageExpense() => _statisticsService.getAverageExpense(_expenses);

  Map<int, double> get monthlyTotals =>
      _statisticsService.getMonthlyTotals(_expenses);

  double getCategoryTotal(ExpenseCategory category) =>
      _statisticsService.getCategoryTotal(_expenses, category);

  Map<DateTime, double> get dailyTotals =>
      _statisticsService.getDailyTotals(_expenses);

  // Filtered expenses
  List<Expense> get filteredExpenses {
    print('Filtering expenses: ${_expenses.length} total expenses');
    return _expenses.where((expense) {
      final matchesCategory =
          _selectedCategory == null || expense.category == _selectedCategory;
      final matchesSearch = expense.description
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'date') {
          return b.date.compareTo(a.date);
        } else {
          return b.amount.compareTo(a.amount);
        }
      });
  }

  // Methods
  Future<void> loadExpenses() async {
    _expenses = await _expenseService.getExpenses();
    print('Loaded expenses: ${_expenses.length}');
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseService.saveExpense(expense);
    await loadExpenses();
    print('Added expense: ${expense.description}');
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseService.updateExpense(expense);
    await loadExpenses();
    print('Updated expense: ${expense.description}');
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.deleteExpense(id);
    await loadExpenses();
    print('Deleted expense with ID: $id');
  }

  // Filter methods
  void setCategory(ExpenseCategory? category) {
    _selectedCategory = category;
    print('Set category filter: $category');
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    print('Set search query: $query');
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    print('Set sort by: $sort');
    notifyListeners();
  }

  // Statistics methods
  Map<DateTime, double> getDailyTotals() {
    return _statisticsService.getDailyTotals(_expenses);
  }

  Future<void> deleteAllExpenses() async {
    await _expenseService.deleteAllExpenses();
    await loadExpenses();
    print('Deleted all expenses');
  }
}
