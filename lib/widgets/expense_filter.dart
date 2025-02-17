import 'package:flutter/material.dart';
import 'package:personal_expense/model/expense_model.dart';

class ExpenseFilter extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final void Function(ExpenseCategory?) onCategoryChanged;
  final String searchQuery;
  final void Function(String) onSearchChanged;
  final String sortBy;
  final void Function(String) onSortChanged;

  const ExpenseFilter({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortBy,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: onSearchChanged,
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
                selected: selectedCategory == null,
                onSelected: (selected) {
                  if (selected) onCategoryChanged(null);
                },
              ),
              ...ExpenseCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category.toString().split('.').last),
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      onCategoryChanged(selected ? category : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        DropdownButton<String>(
          value: sortBy,
          items: const [
            DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
            DropdownMenuItem(value: 'amount', child: Text('Sort by Amount')),
          ],
          onChanged: (value) => onSortChanged(value!),
        ),
      ],
    );
  }
}
