import 'dart:convert';

enum ExpenseCategory {
  food,
  transportation,
  entertainment,
  utilities,
  shopping,
  other
}

class Expense {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final ExpenseCategory category;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category.toString(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
    );
  }
}
