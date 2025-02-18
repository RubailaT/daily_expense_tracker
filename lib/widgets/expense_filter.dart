import 'package:flutter/material.dart';
import 'package:personal_expense/provider/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:personal_expense/model/expense_model.dart';

class ExpenseFilter extends StatelessWidget {
  const ExpenseFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) => provider.setSearchQuery(value),
                decoration: const InputDecoration(
                  labelText: 'Search expenses',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: provider.selectedCategory == null,
                    onSelected: (selected) {
                      if (selected) provider.setCategory(null);
                    },
                  ),
                  ...ExpenseCategory.values.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: Text(category.toString().split('.').last),
                        selected: provider.selectedCategory == category,
                        onSelected: (selected) {
                          provider.setCategory(selected ? category : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            DropdownButton<String>(
              value: provider.sortBy,
              items: const [
                DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
                DropdownMenuItem(
                    value: 'amount', child: Text('Sort by Amount')),
              ],
              onChanged: (value) => provider.setSortBy(value!),
            ),
          ],
        );
      },
    );
  }
}
