import 'package:hive/hive.dart';
import 'package:shiftly/utils/number_utils.dart';

part 'expense.g.dart';

@HiveType(typeId: 3)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String description;

  @HiveField(3)
  double amount;

  @HiveField(4)
  bool isIncome;

  Expense({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    this.isIncome = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'description': description,
    'amount': amount,
    'isIncome': isIncome,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'].toString(),
    date: DateTime.parse(json['date']),
    description: json['description']?.toString() ?? '',
    amount: NumberUtils.parseDouble(json['amount']),
    isIncome: NumberUtils.parseBool(json['isIncome'] ?? json['is_income']),
  );
}
