import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense/model/expense_model.dart';
import 'package:personal_expense/screens/expense_form.dart';
import 'package:personal_expense/service_utils/expense_service.dart';
import 'package:personal_expense/service_utils/notification_service.dart';
import 'package:personal_expense/service_utils/statistics_service.dart';
import 'package:personal_expense/widgets/expense_chart.dart';
import 'package:personal_expense/widgets/expense_filter.dart';
import 'package:personal_expense/widgets/notification_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExpenseService _expenseService = ExpenseService();
  final StatisticsService _statisticsService = StatisticsService();
  final NotificationService _notificationService = NotificationService();
  List<Expense> expenses = [];
  ExpenseCategory? _selectedCategory;
  String _searchQuery = '';
  String _sortBy = 'date';

  Future<void> _checkExpenseLimit() async {
    final totalExpenses = _statisticsService.getTotalExpenses(expenses);
    final limit = 1000.0; // Set your desired limit

    if (totalExpenses > limit) {
      await _notificationService.showInstantNotification(
        title: 'Expense Limit Warning',
        body:
            'Your total expenses (\$${totalExpenses.toStringAsFixed(2)}) have exceeded the limit of \$${limit.toStringAsFixed(2)}',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses().then((_) => _checkExpenseLimit());
    _initializeNotifications();
  }

  Future<void> _showWeeklySummary() async {
    final weeklyTotal = _statisticsService.getTotalExpenses(
      expenses.where((e) {
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        return e.date.isAfter(weekAgo);
      }).toList(),
    );

    await _notificationService.showInstantNotification(
      title: 'Weekly Expense Summary',
      body:
          'Your total expenses this week: \$${weeklyTotal.toStringAsFixed(2)}',
    );
  }

  void _testNotification() async {
    final notificationService = NotificationService();

    // Test immediate notification
    await notificationService.showInstantNotification(
      title: 'New Expense Added',
      body: 'You\'ve successfully added a new expense!',
    );
  }

  Future<void> _initializeNotifications() async {
    // await _notificationService.initialize();
    // await _notificationService.scheduleDailyReminder(
    //   time: const TimeOfDay(hour: 20, minute: 0),
    //   isActive: true,
    // );
  }

  Future<void> _loadExpenses() async {
    final loadedExpenses = await _expenseService.getExpenses();
    setState(() {
      expenses = loadedExpenses;
    });
  }

  List<Expense> get filteredExpenses {
    return expenses.where((expense) {
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

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: ExpenseForm(
            onSubmit: (expense) async {
              await _expenseService.saveExpense(expense);
              _loadExpenses();

              // Show notification for new expense
              await _notificationService.showInstantNotification(
                title: 'New Expense Added',
                body:
                    'Added ${expense.description} for \$${expense.amount.toStringAsFixed(2)}',
              );
            },
          ),
        );
      },
    );
  }

  void _showEditExpenseDialog(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: ExpenseForm(
            expense: expense,
            onSubmit: (updatedExpense) async {
              await _expenseService.updateExpense(updatedExpense);
              _loadExpenses();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _statisticsService.getCategoryTotals(expenses);
    final totalExpenses = _statisticsService.getTotalExpenses(expenses);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: _showWeeklySummary,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationSettingsPage(
                      //       onSettingChanged: () {
                      //   _initializeNotifications();
                      // }
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Expenses:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '\$${totalExpenses.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters
          ExpenseFilter(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
            },
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
            },
            sortBy: _sortBy,
            onSortChanged: (sort) {
              setState(() => _sortBy = sort);
            },
          ),

          // Chart
          if (expenses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpenseChart(
                categoryTotals: categoryTotals,
                totalExpenses: totalExpenses,
              ),
            ),
          ],

          // Expense List
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          expenses.isEmpty
                              ? 'No expenses yet. Tap + to add one!'
                              : 'No expenses match your filters.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Dismissible(
                        key: Key(expense.id),
                        // In your Dismissible widget's onDismissed callback:
                        onDismissed: (direction) async {
                          await _expenseService.deleteExpense(expense.id);
                          _loadExpenses();

                          // Show notification for deleted expense
                          await _notificationService.showInstantNotification(
                            title: 'Expense Deleted',
                            body: '${expense.description} has been deleted',
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Expense deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  await _expenseService.saveExpense(expense);
                                  _loadExpenses();

                                  // Show notification for restored expense
                                  await _notificationService
                                      .showInstantNotification(
                                    title: 'Expense Restored',
                                    body:
                                        '${expense.description} has been restored',
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: ListTile(
                            onTap: () => _showEditExpenseDialog(expense),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              expense.description,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${expense.category.toString().split('.').last} - ${_formatDate(expense.date)}',
                            ),
                            trailing: Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        tooltip: 'Add Expense',
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.utilities:
        return Icons.home;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
