import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.MMMd();

const uuid = Uuid();

enum Category { Food, Travel, Grocery, Bills, Shopping, Rent, Medical, Others }

const categoryIcons = {
  Category.Bills: Icons.receipt_long,
  Category.Food: Icons.lunch_dining,
  Category.Travel: Icons.flight_takeoff,
  Category.Grocery: Icons.store,
  Category.Shopping: Icons.shopping_cart,
  Category.Rent: Icons.add_home,
  Category.Medical: Icons.medical_services,
  Category.Others: Icons.description
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }

  //static fromMap(Map data) {}
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toString().split('.').last,
    };
  }


  // Create an Expense object from a Map object
  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: Category.values.firstWhere(
        (category) => category.toString().split('.').last == map['category'],
      ),
    );
  }
}

class ExpenseBucket {
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
