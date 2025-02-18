import 'package:flutter/material.dart';
import 'package:personal_expense/model/expense_model.dart';
import 'package:personal_expense/screens/home_screen.dart';
import 'package:uuid/uuid.dart';

class ExpenseForm extends StatefulWidget {
  final Function(Expense) onSubmit;
  final Expense? expense;

  const ExpenseForm({
    Key? key,
    required this.onSubmit,
    this.expense,
  }) : super(key: key);

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _selectedDate = widget.expense?.date ?? DateTime.now();
    _selectedCategory = widget.expense?.category ?? ExpenseCategory.other;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
          ListTile(
            title: const Text('Date'),
            subtitle: Text(_selectedDate.toString().split(' ')[0]),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final expense = Expense(
                  id: widget.expense?.id ?? const Uuid().v4(),
                  amount: double.parse(_amountController.text),
                  description: _descriptionController.text,
                  date: _selectedDate,
                  category: _selectedCategory,
                );
                widget.onSubmit(expense);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen(
                            title: "",
                          )),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
