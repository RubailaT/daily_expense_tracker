import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense/provider/expense_provider.dart';
import 'package:personal_expense/provider/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:personal_expense/model/expense_model.dart';
import 'package:personal_expense/screens/expense_form.dart';
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
  @override
  void initState() {
    super.initState();
    // Load expenses when the page initializes
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    await context.read<ExpenseProvider>().loadExpenses();
    await _checkExpenseLimit();
  }

  Future<void> _checkExpenseLimit() async {
    final totalExpenses = context.read<ExpenseProvider>().totalExpenses;
    final limit = 1000.0;

    if (totalExpenses > limit) {
      await context.read<NotificationProvider>().showInstantNotification(
            title: 'Expense Limit Warning',
            body:
                'Your total expenses (\$${totalExpenses.toStringAsFixed(2)}) have exceeded the limit of \$${limit.toStringAsFixed(2)}',
          );
    }
  }

  Future<void> _showWeeklySummary() async {
    final provider = context.read<ExpenseProvider>();
    final weeklyTotal = provider.expenses.where((e) {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      return e.date.isAfter(weekAgo);
    }).fold(0.0, (sum, expense) => sum + expense.amount);

    await context.read<NotificationProvider>().showInstantNotification(
          title: 'Weekly Expense Summary',
          body:
              'Your total expenses this week: \$${weeklyTotal.toStringAsFixed(2)}',
        );
  }

  // In your HomePage class
  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // Add explicit BuildContext type
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: ExpenseForm(
            onSubmit: (expense) async {
              // Pop the form first
              Navigator.of(context).pop();

              // Then perform the operations
              await context.read<ExpenseProvider>().addExpense(expense);
              if (context.mounted) {
                await context
                    .read<NotificationProvider>()
                    .showInstantNotification(
                      title: 'New Expense Added',
                      body:
                          'Added ${expense.description} for \$${expense.amount.toStringAsFixed(2)}',
                    );
              }
            },
          ),
        );
      },
    );
  }

// Update notification settings navigation
// IconButton(
//   icon: const Icon(Icons.notifications),
//   onPressed: () {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => const NotificationSettingsPage(),
//       ),
//     );
//   },
// ),

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
              await context
                  .read<ExpenseProvider>()
                  .updateExpense(updatedExpense);
              await context
                  .read<NotificationProvider>()
                  .showInstantNotification(
                    title: 'Expense Updated',
                    body: 'Updated ${updatedExpense.description}',
                  );
            },
          ),
        );
      },
    );
  }

// ... rest of the HomePage code ...
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final filteredExpenses = expenseProvider.filteredExpenses;
        final totalExpenses = expenseProvider.totalExpenses;
        print('Building HomePage with ${filteredExpenses.length} expenses');

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
                      builder: (context) => const NotificationSettingsPage(),
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
              const ExpenseFilter(),

              // Chart
              if (expenseProvider.expenses.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ExpenseChart(),
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
                              expenseProvider.expenses.isEmpty
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
                            onDismissed: (direction) async {
                              await expenseProvider.deleteExpense(expense.id);

                              await context
                                  .read<NotificationProvider>()
                                  .showInstantNotification(
                                    title: 'Expense Deleted',
                                    body:
                                        '${expense.description} has been deleted',
                                  );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Expense deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () async {
                                        await expenseProvider
                                            .addExpense(expense);

                                        await context
                                            .read<NotificationProvider>()
                                            .showInstantNotification(
                                              title: 'Expense Restored',
                                              body:
                                                  '${expense.description} has been restored',
                                            );
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                onTap: () => _showEditExpenseDialog(expense),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Icon(
                                    _getCategoryIcon(expense.category),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  expense.description,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
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
      },
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
