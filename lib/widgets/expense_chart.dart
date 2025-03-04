import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_expense/provider/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:personal_expense/model/expense_model.dart';

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final categoryTotals = provider.categoryTotals;
        final totalExpenses = provider.totalExpenses;

        return SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: categoryTotals.entries.map((entry) {
                final category = entry.key.toString().split('.').last;
                final amount = entry.value;
                final percentage =
                    totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;

                return PieChartSectionData(
                  color: _getCategoryColor(entry.key),
                  value: amount,
                  title: '$category\n${percentage.toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.red;
      case ExpenseCategory.transportation:
        return Colors.blue;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.utilities:
        return Colors.orange;
      case ExpenseCategory.shopping:
        return Colors.green;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }
}
